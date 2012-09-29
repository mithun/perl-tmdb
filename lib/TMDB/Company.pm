package TMDB::Company;

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
    my $self = shift;
    return $self->session->talk( { method => 'company/' . $self->id(), } );
}

## ====================
## VERSION
## ====================
sub version {
    my ($self) = @_;
    my $response = $self->session->talk(
        {
            method       => 'company/' . $self->id(),
            want_headers => 1,
        }
    ) or return;
    my $version = $response->{etag} || q();
    $version =~ s{"}{}gx;
    return $version;
} ## end sub version

## ====================
## MOVIES
## ====================
sub movies {
    my ($self) = @_;
    return $self->_movies(
        { method => 'company/' . $self->id() . '/movies', } );
}

## ====================
## INFO HELPERS
## ====================

# Name
sub name {
    my ($self) = @_;
    my $info = $self->info();
    return unless $info;
    return $info->{name} || q();
} ## end sub name

# Logo
sub logo {
    my ($self) = @_;
    my $info = $self->info();
    return unless $info;
    return $info->{logo_path} || q();
} ## end sub logo

# Image
sub image { return shift->logo(); }

#######################
# PRIVATE METHODS
#######################

## ====================
## Movie list
## ====================
sub _movies {
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
} ## end sub _movies

#######################
1;
