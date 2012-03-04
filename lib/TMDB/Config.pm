package TMDB::Config;

#######################
# LOAD CORE MODULES
#######################
use strict;
use warnings FATAL => 'all';
use Carp qw(croak carp);

#######################
# LOAD CPAN MODULES
#######################
use Params::Validate qw(validate_with OBJECT SCALAR);
use Object::Tiny qw(
    session
    config
    img_backdrop_sizes
    img_base_url
    img_poster_sizes
    img_profile_sizes
    img_default_size
);

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
            img_default_size => {
                type     => SCALAR,
                optional => 1,
                default  => 'original',
            },
        },
    );

    my $self = $class->SUPER::new(%opts);

    my $config = $self->session->talk( { method => 'configuration' } ) || {};
    $opts{config}             = $config;
    $opts{img_backdrop_sizes} = $config->{images}->{backdrop_sizes} || [];
    $opts{img_poster_sizes}   = $config->{images}->{poster_sizes} || [];
    $opts{img_profile_sizes}  = $config->{images}->{profile_sizes} || [];
    $opts{img_base_url}       = $config->{images}->{base_url} || q();

    return $self;
} ## end sub new

#######################
1;
