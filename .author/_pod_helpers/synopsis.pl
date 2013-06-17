
###############
## Synopsis
###############

use TMDB;

# Initialize
my $tmdb = TMDB->new( apikey => 'xxxxxxxxxx' );

# Search
# =======

# Search for a movie
my @results = $tmdb->search->movie('Snatch');
foreach my $result (@results) {
    printf( "%s:\t%s (%s)\n",
        $result->{id}, $result->{title}, split( /-/, $result->{release_date}, 1 ) );
} ## end foreach my $result (@results)

# Search for an actor
my @results = $tmdb->search->person('Sean Connery');
foreach my $result (@results) {
    printf( "%s:\t%s\n", $result->{id}, $result->{name} );
}

# Movie Data
# ===========

# Movie Object
my $movie = $tmdb->movie( id => '107' );

# Movie details
my $movie_title     = $movie->title;
my $movie_year      = $movie->year;
my $movie_tagline   = $movie->tagline;
my $movie_overview  = $movie->overview;
my @movie_directors = $movie->director;
my @movie_actors    = $movie->actors;

printf( "%s (%s)\n%s", $movie_title, $movie_year,
    '=' x length($movie_title) );
printf( "Tagline: %s\n",     $movie_tagline );
printf( "Overview: %s\n",    $movie_overview );
printf( "Directed by: %s\n", join( ',', @movie_directors ) );
print("\nCast:\n");
printf( "\t-%s\n", $_ ) for @movie_actors;

# Person Data
# ===========

# Person Object
my $person = $tmdb->person( id => '1331' );

# Person Details
my $person_name   = $person->name;
my $person_bio    = $person->bio;
my @person_movies = $person->starred_in;

printf( "%s\n%s\n%s\n",
    $person_name, '=' x length($person_name), $person_bio );
print("\nActed in:\n");
printf( "\t-%s\n", $_ ) for @person_movies;

###############
# INIT
###############

# Initialize
my $tmdb = TMDB->new(
    apikey => 'xxxxxxxxxx...',  # API Key
    lang   => 'en',             # A valid ISO 639-1 (Aplha-2) language code
    client => $http_tiny,       # A valid HTTP::Tiny object
    json   => $json_object,     # A Valid JSON object
);

###############
# CONFIG
###############

# Get Config
my $config = $tmdb->config;
print Dumper $config->config;  # Get all of it

# Get the base URL
my $base_url = $config->img_base_url();

# Sizes (All are array-refs)
my $poster_sizes   = $config->img_poster_sizes();
my $backdrop_sizes = $config->img_backdrop_sizes();
my $profile_sizes  = $config->img_profile_sizes();

###############
# SEARCH
###############

# Configuration
my $search = $tmdb->search(
    include_adult => 'false',  # Include adult results. 'true' or 'false'
    max_pages     => 5,        # Max number of paged results
);

# Search Movies
my $search  = $tmdb->search();
my @results = $search->movie('Avatar');  # Search by Name
my @results = $search->movie('Snatch (2000)'); # Include a Year for better results

# Search People
my $search  = $tmdb->search();
my @results = $search->person('Brad Pitt');    # Search by Name

# Search Companies
my $search  = $tmdb->search();
my @results = $search->company('Sony Pictures');  # Search by Name

# Get Lists
my $lists       = $tmdb->search();
my $latest      = $lists->latest();       # Latest movie added to TheMovieDB
my @now_playing = $lists->now_playing();  # What's currently in theaters
my @popular     = $lists->popular();      # What's currently popular
my @top_rated   = $lists->top_rated();    # Get the top rated list

###############
# MOVIE
###############

# Get the movie object
my $movie = $tmdb->movie( id => '49521' );

# Movie Data (as returned by the API)
use Data::Dumper qw(Dumper);
print Dumper $movie->info;
print Dumper $movie->alternative_titles;
print Dumper $movie->cast;
print Dumper $movie->crew;
print Dumper $movie->images;
print Dumper $movie->keywords;
print Dumper $movie->releases;
print Dumper $movie->trailers;
print Dumper $movie->translations;
print Dumper $movie->lists;
print Dumper $movie->reviews;
print Dumper $movie->changes;

# Filtered Movie data
print $movie->title;
print $movie->year;
print $movie->tagline;
print $movie->overview;
print $movie->description;         # Same as `overview`
print $movie->genres;
print $movie->imdb_id;
print $movie->collection;          # Collection ID
print $movie->actors;              # Names of Actors
print $movie->director;            # Names of Directors
print $movie->producer;            # Names of Producers
print $movie->executive_producer;  # Names of Executive Producers
print $movie->writer;              # Names of Writers/Screenplay

# Images
print $movie->poster;              # Main Poster
print $movie->posters;             # list of posters
print $movie->backdrop;            # Main backdrop
print $movie->backdrops;           # List of backdrops
print $movie->trailers_youtube;    # List of Youtube trailers URLs

# Latest Movie on TMDB
print Dumper $movie->latest;

# Get TMDB's version to check if anything changed
print $movie->version;

###############
# PERSON
###############

# Get the person object
my $person = $tmdb->person( id => '1331' );

# Movie Data (as returned by the API)
use Data::Dumper qw(Dumper);
print Dumper $person->info;
print Dumper $person->credits;
print Dumper $person->images;

# Filtered Person data
print $person->name;
print $person->aka;                 # Also Known As (list of names)
print $person->bio;
print $person->image;               # Main profile image
print $person->starred_in;          # List of titles (as cast)
print $person->directed;            # list of titles Directed
print $person->produced;            # list of titles produced
print $person->executive_produced;  # List of titles as an Executive Producer
print $person->wrote;               # List of titles as a writer/screenplay

# Get TMDB's version to check if anything changed
print $person->version;

###############
# COLLECTION
###############

# Get the collection object
my $collection = $tmdb->collection( id => '2344' );

# Collection data (as returned by the API)
use Data::Dumper;
print Dumper $collection->info;

# Filtered Collection Data
print $collection->titles;  # List of titles in the collection
print $collection->ids;     # List of movie IDs in the collection

# Get TMDB's version to check if anything changed
print $collection->version;

###############
# COMPANY
###############

# Get the company object
my $company = $tmdb->company( id => '1' );

# Company info (as returned by the API)
use Data::Dumper qw(Dumper);
print Dumper $company->info;
print Dumper $company->movies;

# Filtered company data
print $company->name;  # Name of the Company
print $company->logo;  # Logo

# Get TMDB's version to check if anything changed
print $company->version;

###############
# GENRE
###############

# Get a list
my @genres = $tmdb->genre->list();

# Get a list of movies
my @movies = $tmdb->genre( id => '35' )->movies;
