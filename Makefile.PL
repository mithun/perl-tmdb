use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'TMDB',
    AUTHOR              => 'Mithun Ayachit <mithun@cpan.org>',
    VERSION_FROM        => 'lib/TMDB.pm',
    ABSTRACT_FROM       => 'lib/TMDB.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'TMDB-*' },
    META_ADD => {
        resources => {
            bugtracker =>
              'http://rt.cpan.org/NoAuth/Bugs.html?Dist=TMDB',
            repository => 'http://github.com/mithun/perl-tmdb',
        },
);
