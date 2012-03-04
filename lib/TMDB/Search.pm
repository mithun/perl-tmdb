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
use Object::Tiny qw(session include_adult);
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
                type     => SCALAR,
                optional => 1,
                default  => 'false',
            }
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
## Person
## ====================
sub person {
    my ( $self, $string ) = @_;
    return $self->_search(
        {
            method => 'search/person',
            params => { query => $string, },
        }
    );
} ## end sub person

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
        $args->{params}->{page} = $response->{page} + 1;
        my $next_page = $self->session->talk($args);
        push @$results, @{ $next_page->{results} },;
    } ## end if ( $response->{page}...)

    # Done
    return @$results if wantarray;
    return $results;
} ## end sub _search

#######################
1;
