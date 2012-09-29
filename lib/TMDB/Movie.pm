package TMDB::Movie;

#######################
# LOAD CORE MODULES
#######################
use strict;
use warnings FATAL => 'all';
use Carp qw(croak carp);

#######################
# LOAD CPAN MODULES
#######################
use Object::Tiny qw(id session max_pages);
use Locale::Codes::Country qw(all_country_codes);
use Params::Validate qw(validate_with SCALAR OBJECT);

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
            id        => { type => SCALAR, },
            max_pages => {
                type      => SCALAR,
                optional  => 1,
                default   => 5,
                callbacks => { 'integer' => sub { $_[0] =~ m{\d+} }, },
            },
        },
    );

    my $self = $class->SUPER::new(%opts);
    return $self;
} ## end sub new

## ====================
## INFO
## ====================
sub info {
    my $self   = shift;
    my $params = {};
    $params->{lang} = $self->session->lang if $self->session->lang;
    my $info = $self->session->talk(
        {
            method => 'movie/' . $self->id,
            params => $params
        }
    );
    return unless $info;
    $self->{id} = $info->{id};  # Reset TMDB ID
    return $info;
} ## end sub info

## ====================
## ALTERNATIVE TITLES
## ====================
sub alternative_titles {
    my $self    = shift;
    my $country = shift;

    # Valid Country codes
    if ($country) {
        my %valid_country_codes
            = map { $_ => 1 } all_country_codes('alpha-2');
        $country = uc $country;
        return unless $valid_country_codes{$country};
    } ## end if ($country)

    my $args = {
        method => 'movie/' . $self->id() . '/alternative_titles',
        params => {},
    };
    $args->{params}->{country} = $country if $country;

    my $response = $self->session->talk($args);
    my $titles = $response->{titles} || [];

    return @$titles if wantarray;
    return $titles;
} ## end sub alternative_titles

## ====================
## CAST
## ====================
sub cast {
    my $self     = shift;
    my $response = $self->_cast();
    my $cast     = $response->{cast} || [];
    return @$cast if wantarray;
    return $cast;
} ## end sub cast

## ====================
## CREW
## ====================
sub crew {
    my $self     = shift;
    my $response = $self->_cast();
    my $crew     = $response->{crew} || [];
    return @$crew if wantarray;
    return $crew;
} ## end sub crew

## ====================
## IMAGES
## ====================
sub images {
    my $self   = shift;
    my $params = {};
    $params->{lang} = $self->session->lang if $self->session->lang;
    return $self->session->talk(
        {
            method => 'movie/' . $self->id() . '/images',
            params => $params
        }
    );
} ## end sub images

## ====================
## KEYWORDS
## ====================
sub keywords {
    my $self     = shift;
    my $response = $self->session->talk(
        { method => 'movie/' . $self->id() . '/keywords' } );
    my $keywords_dump = $response->{keywords} || [];
    my @keywords;
    foreach (@$keywords_dump) { push @keywords, $_->{name}; }
    return @keywords if wantarray;
    return \@keywords;
} ## end sub keywords

## ====================
## RELEASES
## ====================
sub releases {
    my $self     = shift;
    my $response = $self->session->talk(
        { method => 'movie/' . $self->id() . '/releases' } );
    my $countries = $response->{countries} || [];
    return @$countries if wantarray;
    return $countries;
} ## end sub releases

## ====================
## TRAILERS
## ====================
sub trailers {
    my $self = shift;
    return $self->session->talk(
        { method => 'movie/' . $self->id() . '/trailers' } );
}

## ====================
## TRANSLATIONS
## ====================
sub translations {
    my $self     = shift;
    my $response = $self->session->talk(
        { method => 'movie/' . $self->id() . '/translations' } );
    my $translations = $response->{translations} || [];
    return @$translations if wantarray;
    return $translations;
} ## end sub translations

## ====================
## SIMILAR MOVIES
## ====================
sub similar {
    my ($self) = @_;
    return $self->_similar_movies(
        { method => 'movie/' . $self->id() . '/similar_movies', } );
}
sub similar_movies { return shift->similar(@_); }

## ====================
## VERSION
## ====================
sub version {
    my ($self) = @_;
    my $response = $self->session->talk(
        {
            method       => 'movie/' . $self->id(),
            want_headers => 1,
        }
    ) or return;
    my $version = $response->{etag} || q();
    $version =~ s{"}{}gx;
    return $version;
} ## end sub version

## ====================
## INFO HELPERS
## ====================

# Title
sub title {
    my ($self) = @_;
    my $info = $self->info();
    return unless $info;
    return $info->{title} || q();
} ## end sub title

# Release Year
sub year {
    my ($self) = @_;
    my $info = $self->info();
    return unless $info;
    my $full_date = $info->{release_date} || q();
    return unless $full_date;
    my ($year) = split( /\-/, $full_date );
    return $year;
} ## end sub year

# Tagline
sub tagline {
    my ($self) = @_;
    my $info = $self->info();
    return unless $info;
    return $info->{tagline} || q();
} ## end sub tagline

# Overview
sub overview {
    my ($self) = @_;
    my $info = $self->info();
    return unless $info;
    return $info->{overview} || q();
} ## end sub overview

# IMDB ID
sub imdb_id {
    my ($self) = @_;
    my $info = $self->info();
    return unless $info;
    return $info->{imdb_id} || q();
} ## end sub imdb_id

# Description
sub description { return shift->overview(); }

# Collection
sub collection {
    my ($self) = @_;
    my $info = $self->info();
    return unless $info;
    return $info->{belongs_to_collection}->{id} || q();
} ## end sub collection

# Genres
sub genres {
    my $self = shift;
    my $info = $self->info();
    my @genres;
    if ( exists $info->{genres} ) {
        foreach ( @{ $info->{genres} } ) { push @genres, $_->{name}; }
    }

    return @genres if wantarray;
    return \@genres;
} ## end sub genres

## ====================
## CAST/CREW HELPERS
## ====================

# Actor names
sub actors {
    my $self = shift;
    my @cast = $self->cast();
    my @names;
    foreach (@cast) { push @names, $_->{name}; }
    return @names if wantarray;
    return \@names;
} ## end sub actors

# Crew member names
sub director           { return shift->_crew_names('Director'); }
sub producer           { return shift->_crew_names('Producer'); }
sub executive_producer { return shift->_crew_names('Executive Producer'); }
sub writer { return shift->_crew_names('Screenplay|Writer|Author|Novel'); }

## ====================
## IMAGE HELPERS
## ====================

# Poster
sub poster {
    my $self = shift;
    return $self->info()->{poster_path} || q();
}

# Posters
sub posters {
    my $self     = shift;
    my $response = $self->images();
    my $posters  = $response->{posters} || [];
    return $self->_image_urls($posters);
} ## end sub posters

# Backdrop
sub backdrop {
    my $self = shift;
    return $self->info()->{backdrop_path} || q();
}

# Backdrops
sub backdrops {
    my $self      = shift;
    my $response  = $self->images();
    my $backdrops = $response->{backdrops} || [];
    return $self->_image_urls($backdrops);
} ## end sub backdrops

## ====================
## TRAILER HELPERS
## ====================
sub trailers_youtube {
    my $self     = shift;
    my $trailers = $self->trailers();
    my @urls;
    my $yt_tmp = $trailers->{youtube} || [];
    foreach (@$yt_tmp) {
        push @urls, 'http://youtu.be/' . $_->{source};
    }
    return @urls if wantarray;
    return \@urls;
} ## end sub trailers_youtube

#######################
# PRIVATE METHODS
#######################

## ====================
## CAST
## ====================
sub _cast {
    my $self = shift;
    return $self->session->talk(
        { method => 'movie/' . $self->id() . '/casts', } );
}

## ====================
## CREW NAMES
## ====================
sub _crew_names {
    my $self = shift;
    my $job  = shift;

    my @names;
    my @crew = $self->crew();
    foreach (@crew) {
        push @names, $_->{name} if ( $_->{job} =~ m{$job}xi );
    }

    return @names if wantarray;
    return \@names;
} ## end sub _crew_names

## ====================
## IMAGE URLS
## ====================
sub _image_urls {
    my $self   = shift;
    my $images = shift;
    my @urls;
    foreach (@$images) {
        push @urls, $_->{file_path};
    }
    return @urls if wantarray;
    return \@urls;
} ## end sub _image_urls

## ====================
## SIMILAR MOVIES
## ====================
sub _similar_movies {
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
} ## end sub _similar_movies

#######################
1;
