package TMDB::Person;

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
    return $self->session->talk( { method => 'person/' . $self->id(), } );
}

## ====================
## CREDITS
## ====================
sub credits {
    my $self = shift;
    return $self->session->talk(
        { method => 'person/' . $self->id() . '/credits', } );
}

## ====================
## IMAGES
## ====================
sub images {
    my $self     = shift;
    my $response = $self->session->talk(
        { method => 'person/' . $self->id() . '/images', } );
    return $response->{profiles} || [];
} ## end sub images

## ====================
## INFO HELPERS
## ====================

# Name
sub name {
    my $name = shift->info()->{name} || q();
    return $name;
}

# Alternative names
sub aka {
    my @aka = shift->info()->{also_known_as} || [];
    return @aka if wantarray;
    return \@aka;
}

# Bio
sub bio {
    my $bio = shift->info()->{biography} || q();
    return $bio;
}

# Image
sub image {
    my $img = shift->info()->{profile_path} || q();
    return $img;
}

## ====================
## CREDIT HELPERS
## ====================

# Acted in
sub starred_in {
    my $self = shift;
    my $movies = $self->credits()->{cast} || [];
    my @names;
    foreach (@$movies) { push @names, $_->{title}; }
    return @names if wantarray;
    return \@names;
} ## end sub starred_in

# Crew member
sub directed           { return shift->_crew_names('Director'); }
sub produced           { return shift->_crew_names('Producer'); }
sub executive_produced { return shift->_crew_names('Executive Producer'); }
sub wrote             { return shift->_crew_names('Author|Novel|Screenplay|Writer'); }

#######################
# PRIVATE METHODS
#######################

## ====================
## CREW NAMES
## ====================
sub _crew_names {
    my $self = shift;
    my $job  = shift;

    my @names;
    my $crew = $self->credits()->{crew} || [];
    foreach (@$crew) {
        push @names, $_->{title} if ( $_->{job} =~ m{$job}xi );
    }

    return @names if wantarray;
    return \@names;
} ## end sub _crew_names

#######################
1;
