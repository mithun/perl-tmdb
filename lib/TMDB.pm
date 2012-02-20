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
our $VERSION = '0.01';

#######################
# EXPORT
#######################
use base qw(Exporter);
our ( @EXPORT, @EXPORT_OK, %EXPORT_TAGS );

@EXPORT      = qw();
@EXPORT_OK   = qw();
%EXPORT_TAGS = ( all => [qw()] );
Exporter::export_tags('all');
Exporter::export_ok_tags('all');

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
