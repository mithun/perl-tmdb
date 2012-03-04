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
use JSON::Any;
use Encode qw();
use HTTP::Tiny qw();
use URI::Encode qw();
use Locale::Codes::Language qw(all_language_codes);
use Object::Tiny qw(apikey lang client encoder json);
use Params::Validate qw(validate_with SCALAR OBJECT BOOLEAN);

#######################
# PACKAGE VARIABLES
#######################

# Valid language codes
my %valid_lang_codes = map { $_ => 1 } all_language_codes('alpha-2');

# Default Headers
my $default_headers = { Accept => 'application/json', };

# Default User Agent
my $default_ua = 'perl-tmdb-client';

#######################
# PUBLIC METHODS
#######################

## ============
## Constructor
## ============
sub new {
    my $class = shift;
    my %opts  = validate_with(
        params => \@_,
        spec   => {
            apikey => { type => SCALAR, },
            apiurl => {
                type     => SCALAR,
                optional => 1,
                default  => 'http://api.themoviedb.org/3',
            },
            lang => {
                type      => SCALAR,
                optional  => 1,
                callbacks => {
                    'valid language code' =>
                        sub { $valid_lang_codes{ lc $_[0] } },
                },
            },
            client => {
                type     => OBJECT,
                isa      => 'HTTP::Tiny',
                optional => 1,
                default  => HTTP::Tiny->new(
                    agent           => $default_ua,
                    default_headers => $default_headers,
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
                can      => 'Load',
                optional => 1,
                default  => JSON::Any->new(),
            },
            debug => {
                type     => BOOLEAN,
                optional => 1,
                default  => 0,
            },
        },
    );

    $opts{lang} = lc $opts{lang} if $opts{lang};
    my $self = $class->SUPER::new(%opts);
    return $self;
} ## end sub new

## ============
## Talk
## ============
sub talk {
    my ( $self, $args ) = @_;

    # Build Call
    my $url =
        $self->apiurl . '/' . $args->{method} . '?api_key=' . $self->apikey;
    if ( $args->{params} ) {
        $url .= "&${_}=" . $args->{params}->{$_}
            for ( sort { lc $a cmp lc $b } %{ $args->{params} } );
    }

    # Encode
    $url = $self->encoder->encode($url);

    # Talk
    warn "DEBUG: GET -> $url\n" if $self->debug;
    my $response = $self->client->get($url);

    # Debug
    if ( $self->debug ) {
        warn "DEBUG: Got a successful response\n" if $response->{success};
        warn "DEBUG: Got Status -> $response->{status}\n";
        warn "DEBUG: Got Reason -> $response->{reason}\n"
            if $response->{reason};
        warn "DEBUG: Got Headers -> $response->{headers}\n"
            if $response->{headers};
        warn "DEBUG: Got Content -> $response->{content}\n"
            if $response->{content};
    } ## end if ( $self->debug )

    # Return
    return unless $response->{success};  # Error
    return unless $response->{content};  # Blank Content
    return $self->json->Load(
        Encode::encode( 'utf-8-strict', $response->{content} ) )
        ;                                # Real Response
} ## end sub talk

#######################
1;
