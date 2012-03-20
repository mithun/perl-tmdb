package TMDB::Search;

#######################
# LOAD CORE MODULES
#######################
use strict;
use warnings FATAL => 'all';
use Carp qw(croak carp);

#######################
# LOAD CPAN MODULES
#######################
use Object::Tiny qw(session include_adult max_pages);
use Params::Validate qw(validate_with OBJECT SCALAR);

#######################
# LOAD DIST MODULES
#######################
use TMDB::Session;

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
            session => {
                type => OBJECT,
                isa  => 'TMDB::Session',
            },
            include_adult => {
                type      => SCALAR,
                optional  => 1,
                default   => 'false',
                callbacks => {
                    'valid flag' =>
                        sub { lc $_[0] eq 'true' or lc $_[0] eq 'false' }
                },
            },
            max_pages => {
                type => SCALAR,
                optional => 1,
                default => 5,
                callbacks => {
                  'integer' => sub { $_[0] =~ m{\d+} },  
                },
            },
        },
    );

    my $self = $class->SUPER::new(%opts);
    return $self;
} ## end sub new

## ====================
## Search Movies
## ====================
sub movie {
    my ( $self, $string ) = @_;

    # Get Year
    my $year;
    if ( $string =~ m{.+\((\d{4})\)$} ) {
        $year = $1;
        $string =~ s{\($year\)$}{};
    }

    # Trim
    $string =~ s{(?:^\s+)|(?:\s+$)}{};
    $string .= " $year" if $year;

    # Search
    my $params = {
        query         => $string,
        include_adult => $self->include_adult,
    };
    $params->{lang} = $self->session->lang if $self->session->lang;

    warn "DEBUG: Searching for $string\n" if $self->session->debug;
    return $self->_search(
        {
            method => 'search/movie',
            params => $params,
        }
    );
} ## end sub movie

## ====================
## Search Person
## ====================
sub person {
    my ( $self, $string ) = @_;

    warn "DEBUG: Searching for $string\n" if $self->session->debug;
    return $self->_search(
        {
            method => 'search/person',
            params => { query => $string, },
        }
    );
} ## end sub person

## ====================
## LISTS
## ====================

# Latest
sub latest { return shift->session->talk( { method => 'latest/movie', } ); }

# Now Playing
sub now_playing {
    return shift->_search( { method => 'movie/now-playing', } );
}

# Popular
sub popular { return shift->_search( { method => 'movie/popular', } ); }

# Top rated
sub top_rated { return shift->_search( { method => 'movie/top-rated', } ); }

#######################
# PRIVATE METHODS
#######################

## ====================
## Search
## ====================
sub _search {
    my $self = shift;
    my $args = shift;

    my $response = $self->session->talk($args);
    my $results = $response->{results} || [];

    # Paginate
    if (    $response->{page}
        and $response->{total_pages}
        and ( $response->{total_pages} > $response->{page} ) )
    {
        my $page_limit   = $self->max_pages();
        my $current_page = $response->{page};
        while ($page_limit) {
            $current_page++;
            $args->{params}->{page} = $current_page;
            my $next_page = $self->session->talk($args);
            push @$results, @{ $next_page->{results} },;
            last if ( $next_page->{page} == $next_page->{total_pages} );
            $page_limit--;
        } ## end while ($page_limit)
    } ## end if ( $response->{page}...)

    # Done
    return @$results if wantarray;
    return $results;
} ## end sub _search

#######################
1;
