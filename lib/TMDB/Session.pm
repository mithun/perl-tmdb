package TMDB::Session;

#######################
# LOAD CORE MODULES
#######################
use strict;
use warnings FATAL => 'all';
use Carp qw(croak carp);

#######################
# LOAD CPAN MODULES
#######################
use JSON::MaybeXS;
use Encode qw();
use HTTP::Tiny qw();
use URI::Encode qw();
use Params::Validate qw(validate_with :types);
use Locale::Codes::Language qw(all_language_codes);
use Locale::Codes::Country qw(all_country_codes);
use Object::Tiny qw(_http_options token apikey apiurl lang debug client encoder json);

#######################
# VERSION
#######################
our $VERSION = '1.2.1';

#######################
# PACKAGE VARIABLES
#######################

# Valid language codes
my %valid_lang_codes = map { $_ => 1 } all_language_codes('alpha-2');
my %valid_country_codes = map { uc($_) => 1 } all_country_codes('alpha-2');

# Default Headers
my $default_headers = {
    'Accept'       => 'application/json',
    'Content-Type' => 'application/json',
};

# Default User Agent
my $default_ua = 'perl-tmdb-client';

#######################
# PUBLIC METHODS
#######################

## ====================
## Constructor
## ====================
sub new {
    my $class = shift;
    my %opts  = validate_with(
        params => \@_,
        spec   => {
            apikey => {
                type => SCALAR,
                optional => 1,
                default => undef,
                callbacks => {
                  'incompatible with token' => sub { !($_[0] && $_[1]->{token}) }
                },
            },
            token => {
                type => SCALAR,
                optional => 1,
                default => undef,
                callbacks => {
                  'incompatible with apikey' => sub { !($_[0] && $_[1]->{apikey}) }
                },
            },
            apiurl => {
                type     => SCALAR,
                optional => 1,
                default  => 'https://api.themoviedb.org/3',
            },
            lang => {
                type      => SCALAR,
                optional  => 1,
                callbacks => {
                    'valid language code' =>
                      sub { 
                        my ( $lang, $country ) = split(/-/, $_[0]);
                        $valid_lang_codes{ lc $lang } && !$country
                        || $valid_lang_codes{ $lang } && $valid_country_codes{ $country };
                      },
                },
            },
            client => {
                type     => OBJECT,
                isa      => 'HTTP::Tiny',
                optional => 1,
                default  => HTTP::Tiny->new(
                    agent => $default_ua,
                ),
            },
            encoder => {
                type     => OBJECT,
                isa      => 'URI::Encode',
                optional => 1,
                default  => URI::Encode->new(),
            },
            json => {
                type     => OBJECT,
                can      => [qw(decode)],
                optional => 1,
                default  => JSON::MaybeXS->new(),
            },
            debug => {
                type     => BOOLEAN,
                optional => 1,
                default  => 0,
            },
        },
    );

    $opts{lang} = lc $opts{lang} if $opts{lang} && length($opts{lang}) == 2;
    my $self = $class->SUPER::new(%opts);

    my $headers = { %$default_headers };
    $headers->{Authorization} = 'Bearer '.($self->token) if $self->token;
    $self->{_http_options} = { headers => $headers };
  return $self;
} ## end sub new

## ====================
## Talk
## ====================
sub talk {
    my ( $self, $args ) = @_;

    # Build Call
    my $url = $self->apiurl . '/' . $args->{method};
    $url .= '?api_key=' . $self->apikey if $self->apikey; 
    # add language by default
    $args->{params}->{language} = $self->lang unless (exists $args->{params}->{language});
    if ( $args->{params} ) {
        my $firstparam = ! $self->apikey;
        foreach
          my $param ( sort { lc $a cmp lc $b } keys %{ $args->{params} } )
        {
          next unless defined $args->{params}->{$param};
          if ($firstparam) {
            $url .= "?${param}=" . $args->{params}->{$param};
            $firstparam = 0;
          } else {
            $url .= "&${param}=" . $args->{params}->{$param};
          }
        } ## end foreach my $param ( sort { ...})
    } ## end if ( $args->{params} )

    # Encode
    $url = $self->encoder->encode($url);

    # Talk
    warn "DEBUG: GET -> $url\n" if $self->debug;
    my $response = $self->client->get($url, $self->_http_options);

    # Debug
    if ( $self->debug ) {
        warn "DEBUG: Got a successful response\n" if $response->{success};
        warn "DEBUG: Got Status -> $response->{status}\n";
        warn "DEBUG: Got Reason -> $response->{reason}\n"
          if $response->{reason};
        warn "DEBUG: Got Content -> $response->{content}\n"
          if $response->{content};
    } ## end if ( $self->debug )

    # Return
  return unless $self->_check_status($response);
    if ( $args->{want_headers} and exists $response->{headers} ) {

        # Return headers only
      return $response->{headers};
    } ## end if ( $args->{want_headers...})
  return unless $response->{content};  # Blank Content
  return $self->json->decode(
        Encode::decode( 'utf-8-strict', $response->{content} ) ); # Real Response
} ## end sub talk

## ====================
## PAGINATE RESULTS
## ====================
sub paginate_results {
    my ( $self, $args ) = @_;

    my $response = $self->talk($args);
    my $results = $response->{results} || [];

    # Paginate
    if (    $response->{page}
        and $response->{total_pages}
        and ( $response->{total_pages} > $response->{page} ) )
    {
        my $page_limit = $args->{max_pages} || '1';
        my $current_page = $response->{page};
        while ($page_limit) {
          last if ( $current_page == $page_limit );
            $current_page++;
            $args->{params}->{page} = $current_page;
            my $next_page = $self->talk($args);
            push @$results, @{ $next_page->{results} },;
          last if ( $next_page->{page} == $next_page->{total_pages} );
            $page_limit--;
        } ## end while ($page_limit)
    } ## end if ( $response->{page}...)

    # Done
  return @$results if wantarray;
  return $results;
} ## end sub paginate_results

#######################
# INTERNAL
#######################

# Check Response status
sub _check_status {
    my ( $self, $response ) = @_;

    if ( $response->{success} ) {
      return 1;
    }

    if ( $response->{content} ) {
        my ( $code, $message );
        my $ok = eval {

            my $status = $self->json->decode(
                Encode::decode( 'utf-8-strict', $response->{content} ) );

            $code    = $status->{status_code};
            $message = $status->{status_message};

            1;
        };

        if ( $ok and $code and $message ) {
            carp sprintf( 'TMDB API Error (%s): %s', $code, $message );
        }
    } ## end if ( $response->{content...})

  return;
} ## end sub _check_status

#######################
1;
