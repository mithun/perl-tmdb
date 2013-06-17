#!/usr/bin/perl

####################
# LOAD CORE MODULES
####################
use strict;
use warnings FATAL => 'all';

# Autoflush ON
local $| = 1;

####################
# LOAD CPAN MODULES
####################
use Data::Printer {
    output  => 'stdout',
    colored => 1,
    deparse => 1,
    class   => {
        expand => 2,
    },
};
use Term::ANSIColor qw(colored);
use Getopt::Long qw(GetOptions);

####################
# LOAD DIST MODULES
####################
use FindBin qw($Bin);
use lib "$Bin/../../lib";
use TMDB;

####################
# READ OPTIONS
####################
my %opts = (
    c  => 0,  # Collection
    m  => 0,  # Movies
    s  => 0,  # Search
    p  => 0,  # People
    a  => 0,  # All
    cm => 0,  # Company
    g  => 0,  # Genre
);
GetOptions( \%opts, 'c', 'm', 's', 'p', 'a', 'cm', 'g', )
  or die "Invalid Options";

if ( $opts{a} ) {
    %opts = map { $_ => 1 } keys %opts;
}

####################
# INIT OBJECT
####################
my $apikey = $ENV{PERL_TMDB_API}
  || die "API key is not defined in PERL_TMDB_API";
my $tmdb = TMDB->new(
    apikey => $apikey,
    debug  => 0,
    lang   => 'en',
);
_dump(
    o => $tmdb,
    m => 'Main TMDB Object'
);

####################
# CONFIG
####################
_dump(
    o => [ $tmdb->config->config() ],
    m => 'Config'
);

####################
# SEARCH
####################
if ( $opts{s} ) {
    _dump(
        o => [ $tmdb->search->movie('Snatch (2000)') ],
        m => 'Movie Search'
    );
    _dump(
        o => [ $tmdb->search->person('Brad Pitt') ],
        m => 'Person Search'
    );
    _dump(
        o => [ $tmdb->search->company('Marvel') ],
        m => 'Company Search'
    );
    _dump(
        o => [ $tmdb->search->latest() ],
        m => 'Latest Movie'
    );
    _dump(
        o => [ $tmdb->search->latest_person() ],
        m => 'Latest Person'
    );
    _dump(
        o => [ $tmdb->search( max_pages => 2 )->upcoming() ],
        m => 'Upcoming'
    );
    _dump(
        o => [ $tmdb->search( max_pages => 2 )->now_playing() ],
        m => 'Now Playing'
    );
    _dump(
        o => [ $tmdb->search( max_pages => 2 )->popular() ],
        m => 'Popular Movies'
    );
    _dump(
        o => [ $tmdb->search( max_pages => 2 )->top_rated() ],
        m => 'Top Rated'
    );
    _dump(
        o => [ $tmdb->search( max_pages => 2 )->popular_people() ],
        m => 'Popular People'
    );
} ## end if ( $opts{s} )

####################
# MOVIE
####################
if ( $opts{m} ) {
    my $movie_id = '49521';
    _dump(
        o => $tmdb->movie( id => $movie_id ),
        m => "Movie Object"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->info ],
        m => "Movie Info"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->version ],
        m => "Movie version"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->alternative_titles ],
        m => "Movie alternative_titles"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->cast ],
        m => "Movie cast"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->crew ],
        m => "Movie crew"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->images ],
        m => "Movie images"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->keywords ],
        m => "Movie keywords"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->releases ],
        m => "Movie releases"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->trailers ],
        m => "Movie trailers"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->translations ],
        m => "Movie translations"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->title ],
        m => "Movie title"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->year ],
        m => "Movie year"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->tagline ],
        m => "Movie tagline"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->overview ],
        m => "Movie overview"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->collection ],
        m => "Movie collection"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->genres ],
        m => "Movie genres"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->imdb_id ],
        m => "Movie imdb_id"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->actors ],
        m => "Movie actors"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->director ],
        m => "Movie director"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->producer ],
        m => "Movie producer"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->executive_producer ],
        m => "Movie executive_producer"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->writer ],
        m => "Movie writer"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->poster ],
        m => "Movie poster"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->backdrop ],
        m => "Movie backdrop"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->posters ],
        m => "Movie posters"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->backdrops ],
        m => "Movie backdrops"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->trailers_youtube ],
        m => "Movie trailers_youtube"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->similar ],
        m => "Movie similar"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->lists ],
        m => "Movie lists"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->reviews ],
        m => "Movie reviews"
    );
    _dump(
        o => [ $tmdb->movie( id => $movie_id )->changes ],
        m => "Movie changes"
    );
} ## end if ( $opts{m} )

####################
# PERSON
####################
if ( $opts{p} ) {
    my $person_id = '1331';
    _dump(
        o => $tmdb->person( id => $person_id ),
        m => "Person Object"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->info ],
        m => "Person info"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->version ],
        m => "Person version"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->credits ],
        m => "Person credits"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->images ],
        m => "Person images"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->name ],
        m => "Person name"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->aka ],
        m => "Person aka"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->bio ],
        m => "Person bio"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->image ],
        m => "Person image"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->starred_in ],
        m => "Person starred_in"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->directed ],
        m => "Person directed"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->produced ],
        m => "Person produced"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->executive_produced ],
        m => "Person executive_produced"
    );
    _dump(
        o => [ $tmdb->person( id => $person_id )->wrote ],
        m => "Person wrote"
    );

} ## end if ( $opts{p} )

####################
# COLLECTION
####################
if ( $opts{c} ) {
    my $coll_id = '2344';
    _dump(
        o => $tmdb->collection( id => $coll_id ),
        m => "Collection Object"
    );
    _dump(
        o => [ $tmdb->collection( id => $coll_id )->info ],
        m => "Collection info"
    );
    _dump(
        o => [ $tmdb->collection( id => $coll_id )->version ],
        m => "Collection version"
    );
    _dump(
        o => [ $tmdb->collection( id => $coll_id )->titles ],
        m => "Collection titles"
    );
    _dump(
        o => [ $tmdb->collection( id => $coll_id )->ids ],
        m => "Collection ids"
    );
} ## end if ( $opts{c} )

####################
# COMPANY
####################
if ( $opts{cm} ) {
    my $comp_id = '923';
    _dump(
        o => [ $tmdb->company( id => $comp_id ) ],
        m => "Company Object",
    );
    _dump(
        o => [ $tmdb->company( id => $comp_id )->info ],
        m => "Company info",
    );
    _dump(
        o => [ $tmdb->company( id => $comp_id )->version ],
        m => "Company version",
    );
    _dump(
        o => [ $tmdb->company( id => $comp_id )->name ],
        m => "Company name",
    );
    _dump(
        o => [ $tmdb->company( id => $comp_id )->logo ],
        m => "Company logo",
    );
    _dump(
        o => [ $tmdb->company( id => $comp_id )->movies ],
        m => "Company movies",
    );
} ## end if ( $opts{cm} )

####################
# GENRE
####################
if ( $opts{g} ) {
    _dump(
        o => [ $tmdb->genre()->list ],
        m => "Genre list",
    );
    _dump(
        o => [ $tmdb->genre( id => '35' )->movies ],
        m => "Genre movies",
    );
} ## end if ( $opts{g} )

####################
# DONE
####################
exit 0;

####################
# INTERNAL
####################
sub _dump {
    my (%d) = @_;
    print colored( [qw(bold bright_white)],
        sprintf( "%s\n  -> %s\n%s\n", '#' x 25, uc $d{m}, '#' x 25 ) );
    p $d{o};
  return 1;
} ## end sub _dump
