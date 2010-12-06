use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'TMDB',
    AUTHOR           => 'Mithun Ayachit <mithun@cpan.org>',
    VERSION_FROM     => 'lib/TMDB.pm',
    ABSTRACT_FROM    => 'lib/TMDB.pm',
    LICENSE          => 'perl',
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.8.1',
    BUILD_REQUIRES   => { 'Test::More' => 0, },
    PREREQ_PM        => {
        'Encode'         => 0,
        'LWP::UserAgent' => 0,
        'YAML::Any'      => 0,
    },
    dist     => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean    => { FILES    => 'TMDB-*' },
    META_ADD => {
        resources => {
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=TMDB',
            repository => 'http://github.com/mithun/perl-tmdb',
        }
    },
);
