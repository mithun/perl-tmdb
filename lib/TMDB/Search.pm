package TMDB::Search;

use strict;
use warnings;
use Carp;

use TMDB::Session;

## == Public methods == ##

## Constructor
sub new {
    my $class = shift;
    my $args  = shift;

    my $self = {};
    bless $self, $class;
    $self->{_session} = $args->{session} || croak "Session not provided";
    return $self;
}

## Search Movies
#   Provides searching by title+year
sub movie {
    my $self = shift;
    my @args = @_;

    my ( $title, $year );
    if ( ref $args[0] eq 'HASH' ) {
        $title = $args[0]->{name} if $args[0]->{name};
        $year  = $args[0]->{year}  if $args[0]->{year};
    }
    else { $title = $args[0] }

    # title is required
    croak "No search title provided" unless $title;

    # Check if title contains year
    if ( not $year ) {
        if ( $title =~ s{\(\s*(\d{4})\s*\)$}{}x ) { $year = $1; }
    }

    # Build parameters to pass to session
    my $talk_args = {
        method => 'Movie.search',
        params => $title,
    };
    $talk_args->{params} .= "+${year}" if $year;

    # Fetch results
    my $results = $self->_session->talk($talk_args) or return;

    # Process results
    return _parse_movie_result($results);
}

## Search Person
sub person {
    my $self = shift;
    my $name = shift || croak "Person's name is not provided";

    # Build parameters to pass to session
    my $talk_args = { method => 'Person.search', params => $name };

    # Fetch results
    my $results = $self->_session->talk($talk_args) or return;

    # Process results
    my @persons;
    foreach my $result ( @{$results} ) {
        my %person;
        $person{name} = $result->{name};
        $person{id}   = $result->{id};
        $person{url}  = $result->{url};
        foreach my $image ( @{ $result->{profile} } ) {
            next unless ( $image->{image}->{size} eq 'thumb' );
            $person{thumb} = $image->{image}->{url};
        }
        push @persons, \%person;
    }

    return @persons;
}

## Search IMDB
sub imdb {
    my $self = shift;
    my $imdb_id = shift || croak "IMDB ID is required";

    # Build parameters to pass to session
    my $talk_args = { method => 'Movie.imdbLookup', params => $imdb_id };

    # Fetch results
    my $results = $self->_session->talk($talk_args) or return;

    # Process results
    return _parse_movie_result($results);
}

## Search DVDID
sub dvdid {
    my $self = shift;
    my $dvdid = shift || croak "DVDID not provided";

    # Build parameters to pass to session
    my $talk_args = { method => 'Media.getInfo', params => $dvdid };

    # Fetch results
    my $results = $self->_session->talk($talk_args) or return;

    # Process results
    return _parse_movie_result($results);
}

## Search by file
sub file {
    my $self = shift;
    my $file = shift || croak "Filename not provided";

    # Build parameters to pass to session
    my $talk_args = {
        method => 'Media.getInfo',
        params => join( '/', OpenSubtitlesHash($file), -s $file ),
    };

    # Fetch results
    my $results = $self->_session->talk($talk_args) or return;

    # Process results
    return _parse_movie_result($results);
}

## == Private methods == ##

## Session
sub _session { return shift->{_session}; }

## Search result
sub _parse_movie_result {
    my $results = shift;
    my @movies;
    foreach my $result ( @{$results} ) {
        my %movie;
        $movie{name} = $result->{name};
        $movie{year}  = $result->{released};
        $movie{year} =~ s{\-\d{2}\-\d{2}$}{}x;
        $movie{id}  = $result->{id};
        $movie{url} = $result->{url};
        foreach my $poster ( @{ $result->{posters} } ) {
            next unless ( $poster->{image}->{size} eq 'thumb' );
            $movie{thumb} = $poster->{image}->{url};
            last;
        }
        push @movies, \%movie;
    }
    return @movies;
}

## File hash
#   Hashing source code from 'OpenSubtitles'
#   http://trac.opensubtitles.org/projects/opensubtitles/wiki/HashSourceCodes#Perl
sub OpenSubtitlesHash {
    my $filename = shift or croak("Need video filename");

    open my $handle, "<", $filename or croak $!;
    binmode $handle;

    my $fsize = -s $filename;

    my $hash = [ $fsize & 0xFFFF, ( $fsize >> 16 ) & 0xFFFF, 0, 0 ];

    $hash = AddUINT64( $hash, ReadUINT64($handle) ) for ( 1 .. 8192 );

    my $offset = $fsize - 65536;
    seek( $handle, $offset > 0 ? $offset : 0, 0 ) or croak $!;

    $hash = AddUINT64( $hash, ReadUINT64($handle) ) for ( 1 .. 8192 );

    close $handle or croak $!;
    return UINT64FormatHex($hash);
}

sub ReadUINT64 {
    read( $_[0], my $u, 8 );
    return [ unpack( "vvvv", $u ) ];
}

sub AddUINT64 {
    my $o = [ 0, 0, 0, 0 ];
    my $carry = 0;
    for my $i ( 0 .. 3 ) {
        if ( ( $_[0]->[$i] + $_[1]->[$i] + $carry ) > 0xffff ) {
            $o->[$i] += ( $_[0]->[$i] + $_[1]->[$i] + $carry ) & 0xffff;
            $carry = 1;
        }
        else {
            $o->[$i] += ( $_[0]->[$i] + $_[1]->[$i] + $carry );
            $carry = 0;
        }
    }
    return $o;
}

sub UINT64FormatHex {
    return sprintf( "%04x%04x%04x%04x",
        $_[0]->[3], $_[0]->[2], $_[0]->[1], $_[0]->[0] );
}

#####################
1;
