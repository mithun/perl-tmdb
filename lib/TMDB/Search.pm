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
use Params::Validate qw(validate_with OBJECT);
use Object::Tiny qw();

#######################
# LOAD DIST MODULES
#######################
use TMDB::Session;

#######################
# MODULE METHODS
#######################

## ============
## Constructor
## ============
sub new {
    my $class = shift;
    my %opts  = validate_with(
        params => \@_,
        spec   => {
            session => {
                type => OBJECT,
                isa  => 'TMDB::Session',
            },
        },
    );
} ## end sub new

## ============
## Search Movies
## ============
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
    my $params = { query => $string, };
    $params->{lang} = $self->lang if $self->lang;
    return $self->_search(
        {
            method => 'search/movie',
            params->$params,
        }
    );
} ## end sub movie

## ============
## Person
## ============
sub person {
    my ( $self, $string ) = @_;
    return $self->_search(
        {
            method => 'search/person',
            params => { query => $string, },
        }
    );
} ## end sub person

## Search (Internal)
## ============
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
