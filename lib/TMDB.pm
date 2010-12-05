package TMDB;

use 5.008001;
use strict;
use warnings FATAL => 'all';
use Carp qw(croak);

our $VERSION = '0.01';

use TMDB::Session;
use TMDB::Search;
use TMDB::Movie;
use TMDB::Person;

## == Public methods == ##

## Constructor
sub new {
    my ( $class, $args ) = @_;
    my $self = {};

    # Initialize
    bless $self, $class;
    return $self->_init($args);
}

## Search Object
sub search {
    my $self = shift;
    return TMDB::Search->new( { session => $self->_session } );
}

## Movie Object
sub movie {
    my $self = shift;
    my $id = shift || croak "Movie ID is required";
    return TMDB::Movie->new( { session => $self->_session, id => $id } );
}

## Person Object
sub person {
    my $self = shift;
    my $id = shift || croak "Person ID is required";
    return TMDB::Person->new( { session => $self->_session, id => $id } );
}

## == Private Methods == ##

## Initialize
sub _init {
    my $self = shift;
    my $args = shift || {};

    croak "Hash reference expected" unless ( ref $args eq 'HASH' );

    $args->{_VERSION} = $VERSION;
    $self->{_session} = TMDB::Session->new($args);
    return $self;
}

## Session
sub _session {
    my $self = shift;
    if (@_) { return $self->{_session} = @_; }
    return $self->{_session};
}

################
1;

__END__

=head1 NAME

TMDB - Perl wrapper for The MovieDB API

=head1 VERSION

This document describes TMDB version 0.01

=head1 SYNOPSIS

use TMDB;

    # Initialize
    my $tmdb = TMDB->new( { api_key => 'xxxxxx' } );

    # Search for movies
    my @results = $tmdb->search->movie('Italian Job');
    foreach my $result (@results) {
        print "#$result->{id}: $result->{name} ($result->{year})\n";
    }

    # Get movie info
    my $movie = $tmdb->movie('19995');
    printf( "%s (%s)\n", $movie->name, $movie->year );
    printf( "%s\n", $movie->tagline );
    printf( "Overview: %s\n", $movie->overview );
    printf( "Director: %s\n", join( ',', $movie->director ) );
    printf( "Cast: %s\n",     join( ',', $movie->cast ) );
  
=head1 DESCRIPTION

L<The MovieDB|http://www.themoviedb.org/> is a free and open movie database.
This module provides a Perl wrapper to L<The MovieDB
API|http://api.themoviedb.org>. In order to use this module, you must first get
an API key by L<signing up|http://www.themoviedb.org/account/signup>.

=head1 METHODS

=head2 new(\%options)

    my $tmdb = TMDB->new({api_key => 'xxxxxxx', ua => $ua});

The constructor accepts the following options

=over

=item api_key

Requierd. This is your TMDb API key

=item ua

Optional. You can initialize with your own L<LWP::UserAgent>

=back

=head2 SEARCH

The following search methods are available

=over

=item movie($name)

=item movie({name => $name, year => $year})

    my @results = $tmdb->search->movie('Avatar');           # Using a title
    my @results = $tmdb->search->movie('Avatar (2009)');    # Title includes year
    my @results =
      $tmdb->search->movie( { name => 'Avatar', year => '2009' } );  # Split them up

The search result returned is an array, or undef if nothing is found. Each
element in the result array is a hash ref containing C<name> (movie name),
C<year> (release year), C<id> (TMDb ID), C<thumb> (A thumbnail image URL) and
C<url> (TMDb movie URL).

=item person($name)

    my @results = $tmdb->search->person('George Clooney');

The search result returned is an array, or undef if nothing is found. Each
element in the result array is a hash ref containing C<name> (Person's name),
C<id> (TMDb ID), C<thumb> (A thumbnail image URL) and C<url> (TMDb profile
URL).

=item imdb($imdb_id)

    my @results = $tmdb->search->imdb('tt1542344');

This allows you to search a movie by its IMDB ID. The search result returned is
the same as L</movie($name)>

=item dvdid($dvdid)

    my @results = $tmdb->search->dvdid($dvdid);

This allows you to search a movie by its
L<DVDID|http://www.srcf.ucam.org/~cjk32/dvdid/>. The search result returned is
the same as L</movie($name)>

=item file($filename)

    my @results = $tmdb->search->file($filename);

This allows you to search a movie by passing a file. The file's
L<HashID|http://trac.opensubtitles.org/projects/opensubtitles/wiki/HashSourceCodes>
and size is used to search TMDb. The search result returned is the same as
L</movie($name)>

=back

=head2 movie

    # Initialize using TMDb ID
    my $movie = $tmdb->movie($id);

    # Movie Information
    $movie->name();                   # Get Movie name
    $movie->year();                   # Release year
    $movie->released();               # Release date
    $movie->url();                    # TMDb URL
    $movie->id();                     # TMDb ID
    $movie->imdb_id();                # IMDB ID
    $movie->tagline();                # Movie tagline
    $movie->overview();               # Movie Overview/plot
    $movie->rating();                 # Rating on TMDb
    $movie->runtime();                # Runtime
    $movie->trailer();                # link to YouTube trailer
    $movie->homepage();               # Official homepage
    $movie->certification();          # MPAA certification
    $movie->budget();                 # Budget

    # Cast & Crew
    #   All of these methods returns an array
    $movie->cast();
    $movie->director();
    $movie->producer();
    $movie->writers();

    # Images
    #   Returns an array with image URLs
    $movie->posters($size)
      ; # Specify what size you want (original/mid/cover/thumb). Defaults to 'original'
    $movie->backdrops($size)
      ; # Specify what size you want (original/poster/thumb). Defaults to 'original'

    # Genres
    #   Returns an array
    $movie->genres();

    # Studios
    #   Returns an array
    $movie->studios();

    # ALl in one
    #   Get a flattened hash containing all movie details
    my $info = $movie->info();
    use Data::Dumper;
    print Dumper $info;

=head2 person

    # Initialize using TMDb ID
    my $person = $tmdb->person($id);

    # Details
    $person->name();        # Name
    $person->id();          # TMDb ID
    $person->bio();         # Biography
    $person->birthday();    # Birthday
    $person->url();         # TMDb profile URL

    # Filmography
    #   Returns an array with movie names
    $person->movies();

    # Images
    #   Returns an array with image URLs
    $person->posters($size)
      ;    # Specify what size (original/profile/thumb). Defaults to 'original'

    # ALl in one
    #   Get a flattened hash containing all person details
    my $info = $person->info();
    use Data::Dumper;
    print Dumper $info;

=head1 BUGS AND LIMITATIONS

This module does not (yet) provide capabilities to I<write> to TMDb.

All data returned is encoded to UTF-8

No bugs have been reported.

Please report any bugs or feature requests to C<bug-tmdb@rt.cpan.org>, or
through the web interface at L<http://rt.cpan.org>.

=head1 DEPENDENCIES

L<Encode>

L<LWP::UserAgent>

L<YAML::Any>

=head1 SEE ALSO

L<WWW::TheMovieDB::API|http://code.google.com/p/perl-themoviedb-api>

=head1 AUTHOR

Mithun Ayachit  C<< <mithun@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, Mithun Ayachit C<< <mithun@cpan.org> >>. All rights
reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.

License for embedded L<Hashing Source
Code|http://trac.opensubtitles.org/projects/opensubtitles/wiki/HashSourceCodes>
is GPL

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE
SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE
STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE
SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND
PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE,
YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY
COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE
SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO
LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR
THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

