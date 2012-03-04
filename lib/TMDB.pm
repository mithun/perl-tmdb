package TMDB;

#######################
# LOAD MODULES
#######################
use strict;
use warnings FATAL => 'all';
use Carp qw(croak carp);

#######################
# VERSION
#######################
our $VERSION = '0.04_01';

#######################
# LOAD CPAN MODULES
#######################
use Object::Tiny qw(session);

#######################
# LOAD DIST MODULES
#######################
use TMDB::Config;
use TMDB::Movie;
use TMDB::Person;
use TMDB::Search;
use TMDB::Session;
use TMDB::Collection;

#######################
# PUBLIC METHODS
#######################

## ====================
## CONSTRUCTOR
## ====================
sub new {
    my ( $class, @args ) = @_;
    my $self;
    bless $self, $class;

    # Init Session
    $self->{session} = TMDB::Session->new(@args);
    return $self;
} ## end sub new

## ====================
## TMDB OBJECTS
## ====================
sub collection {
    return TMDB::Collection->new(
        session => shift->session,
        @_
    );
} ## end sub collection

sub config { return TMDB::Config->new( session => shift->session, @_ ); }
sub movie { return TMDB::Movie->new( session => shift->session, @_ ); }
sub person { return TMDB::Person->new( session => shift->session, @_ ); }
sub search { return TMDB::Search->new( session => shift->session, @_ ); }

#######################
1;

__END__

#######################
# POD SECTION
#######################

=pod

=head1 NAME

TMDB

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 DEPENDENCIES

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-tmdb@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/Public/Dist/Display.html?Name=TMDB>

=head1 AUTHOR

Mithun Ayachit C<mithun@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, Mithun Ayachit. All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.

=cut
