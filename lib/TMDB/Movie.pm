package TMDB::Movie;

#######################
# LOAD CORE MODULES
#######################
use strict;
use warnings FATAL => 'all';
use Carp qw(croak carp);

#######################
# LOAD DIST MODULES
#######################
use TMDB::Session;

#######################
# PUBLIC METHODS
#######################

## Constructor
sub new {
    my $class = shift;
    my $args  = shift;

    my $self = {};
    bless $self, $class;
    return $self->_init($args);
} ## end sub new

# Short Accessors
sub info          { return shift->{_info}; }
sub budget        { return shift->info->{budget}; }
sub certification { return shift->info->{certification}; }
sub homepage      { return shift->info->{homepage}; }
sub id            { return shift->info->{id}; }
sub imdb_id       { return shift->info->{imdb_id}; }
sub name          { return shift->info->{name}; }
sub overview      { return shift->info->{overview}; }
sub rating        { return shift->info->{rating}; }
sub released      { return shift->info->{released}; }
sub runtime       { return shift->info->{runtime}; }
sub tagline       { return shift->info->{tagline}; }
sub trailer       { return shift->info->{trailer}; }
sub url           { return shift->info->{url}; }

## Year
sub year {
    my $self     = shift;
    my $released = $self->released();
    $released =~ s{\-\d{2}\-\d{2}$}{}x;
    return $released;
} ## end sub year

## Posters
sub posters {
    my $self = shift;
    my $size = shift || 'original';

    my @posters;
    foreach my $poster ( @{ $self->info->{posters} } ) {
        next unless ( $poster->{image}->{size} =~ m{$size} );
        push @posters, $poster->{image}->{url};
    }
    return @posters;
} ## end sub posters

## Backdrops
sub backdrops {
    my $self = shift;
    my $size = shift || 'original';

    my @backdrops;
    foreach my $backdrop ( @{ $self->info->{backdrops} } ) {
        next unless ( $backdrop->{image}->{size} =~ m{$size} );
        push @backdrops, $backdrop->{image}->{url};
    }
    return @backdrops;
} ## end sub backdrops

## Cast & crew
sub actors   { return shift->_cast('Actor'); }
sub director { return shift->_cast('Director'); }
sub producer { return shift->_cast('Producer'); }
sub author   { return shift->_cast('Author'); }
sub cast     { return shift->actors; }
sub writer   { return shift->author; }

## Genres
sub genres {
    my $self = shift;
    my @genres;
    foreach ( @{ $self->info->{genres} } ) { push @genres, $_->{name}; }
    return @genres;
} ## end sub genres

## Studios
sub studios {
    my $self = shift;
    my @studios;
    foreach ( @{ $self->info->{studios} } ) { push @studios, $_->{name}; }
    return @studios;
} ## end sub studios

#######################
# PRIVATE METHODS
#######################

## Initialize
sub _init {
    my $self = shift;
    my $args = shift;

    $self->{_session} = $args->{session};

    my $talk_args = {
        method => 'Movie.getInfo',
        params => $args->{id},
    };

    # Get info
    my $results = $self->_session->talk($talk_args)
        or croak "No Movie found. Please try searching instead";

    # Store info
    $self->{_info} = $results->[0];
    return $self;
} ## end sub _init

## Session
sub _session { return shift->{_session}; }

## Cast
sub _cast {
    my $self = shift;
    my $job  = shift;
    my @members;
    foreach my $cast ( @{ $self->info->{cast} } ) {
        next unless ( $cast->{job} eq $job );
        push @members, $cast->{name};
    }
    return @members;
} ## end sub _cast

#######################
1;
