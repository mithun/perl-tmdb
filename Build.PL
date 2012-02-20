#!perl

####################
# LOAD MODULES
####################
use strict;
use warnings FATAL => 'all';
use Module::Build;

# Autoflush ON
local $| = 1;

####################
# INIT BUILDER
####################

my $builder = Module::Build->new(
    module_name        => 'TMDB',
    license            => 'perl',
    dist_author        => 'Mithun Ayachit <mithun@cpan.org>',
    configure_requires => { 'Module::Build' => 0.38 },
    build_requires     => {
        'Test::More' => 0,
        'version'    => 0,
    },
    requires => {

    },
    add_to_cleanup     => ['TMDB-*'],
    create_license     => 1,
    create_makefile_pl => 'traditional',
    meta_merge         => {
        keywords  => [],
        resources => {
            bugtracker =>
                'http://rt.cpan.org/Public/Dist/Display.html?Name=TMDB',
            repository => 'git://github.com/mithun/perl-tmdb.git',
            homepage   => 'https://github.com/mithun/perl-tmdb',
        },
    },
);

####################
# CREATE BUILD SCRIPT
####################
$builder->create_build_script();
