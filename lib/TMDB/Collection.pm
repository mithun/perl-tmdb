package TMDB::Collection;

#######################
# LOAD CORE MODULES
#######################
use strict;
use warnings FATAL => 'all';
use Carp qw(croak carp);

#######################
# LOAD CPAN MODULES
#######################
use Object::Tiny qw(id session);
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
            id => { type => SCALAR, },
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
    return $self->session->talk( { method => 'collection/' . $self->id(), } );
}

## ====================
## INFO HELPERS
## ====================

# All titles
sub titles { return shift->_parse_parts('title'); }

# Title IDs
sub ids { return shift->_parse_parts('id'); }

#######################
# PRIVATE METHODS
#######################

sub _parse_parts {
    my $self  = shift;
    my $key   = shift;
    my $info  = $self->info();
    my $parts = $info ? $info->{parts} : [];
    my @stuff;
    foreach my $part (@$parts) {
        next unless $part->{$key};
        push @stuff, $part->{$key};
    }
    return @stuff if wantarray;
    return \@stuff;
} ## end sub _parse_parts

#######################
1;
