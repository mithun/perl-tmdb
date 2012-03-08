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
        'Encode'           => 0,
        'HTTP::Tiny'       => '0.16',
        'JSON::Any'        => '1.23',
        'Locale::Codes'    => '3.20',
        'Object::Tiny'     => '1.03',
        'Params::Validate' => '1.03',
        'URI::Encode'      => '0.05',
    },
    add_to_cleanup     => ['TMDB-*'],
    create_license     => 1,
    create_makefile_pl => 'traditional',
    meta_merge         => {
        keywords  => [qw(movies movie themoviedb tmdb api metadata imdb)],
        resources => {
            bugtracker =>
                'http://rt.cpan.org/Public/Dist/Display.html?Name=TMDB',
            repository => 'git://github.com/mithun/perl-tmdb.git',
            homepage   => 'https://github.com/mithun/perl-tmdb',
        },
    },
);

####################
# PRINT WARNING
####################

# Print a warning message for backwards compatibility
warn <<"COMPAT_MSG";

        !! NOTE !!

        TMDB-v0.04 and higher uses TheMoviDB API version '/3'. This brings
        some significant differences both to the API and the interface this module
        provides, along with updated dependencies for this distribution. If you like to
        continue to use v2.1 API, you can continue to use
        TMDB-0.03x [ https://metacpan.org/release/MITHUN/TMDB-0.03/ ].

COMPAT_MSG

####################
# CREATE BUILD SCRIPT
####################
$builder->create_build_script();
