use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'TMDB',
    license           => 'perl',
    dist_author       => 'Mithun Ayachit <mithun@cpan.org>',
    dist_version_from => 'lib/TMDB.pm',
    requires          => {
        'perl'           => '5.8.1',
        'Encode'         => 0,
        'LWP::UserAgent' => 0,
        'YAML::Any'      => 0,
    },
    build_requires => { 'Test::More' => 0, },
    add_to_cleanup => ['TMDB-*'],
    meta_add       => {
        resources => {
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=TMDB',
            repository => 'http://github.com/mithun/perl-tmdb',
        },
    },
);

$builder->create_build_script();
