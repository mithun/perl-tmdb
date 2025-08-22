#!perl

####################
# LOAD CORE MODULES
####################
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::MockObject;
use TMDB;
use HTTP::Tiny;

# Autoflush ON
local $| = 1;


my $mock = Test::MockObject->new;
$mock->set_isa('HTTP::Tiny');
$mock->set_always( 
    'get',
    {   success => 1,
        status => 200,
        headers => {},
        content => '{ "id": 1234, "results": [], "changes": [], "title": "blabla", "name": "blabla", "overview": "blabla blabla", "credits": { "cast": [], "crew": [] }}'
    }
);

my ($tmdb, $name, $args, $url, $opts);
my $http_options = 

# Test apikey is send as query string parameter
$mock->clear;
$tmdb = TMDB->new( apikey => 'fake-api-key', client => $mock);
$tmdb->{session}->talk( { method => "test/path", params => { para1 => "v1", para2 => "v2" } } );
($name, $args) = $mock->next_call();
$url = @$args[1];
$opts = @$args[2];

is ($url, "https://api.themoviedb.org/3/test/path?api_key=fake-api-key&para1=v1&para2=v2", "API key is passed as query-string parameter");
ok (!$opts->{headers}->{Authorization}, 'No Authorization header in HTTP options');

# Test token is sent in headers as Bearer token
$mock->clear;
$tmdb = TMDB->new( token => 'fake-api-token', client => $mock);
$tmdb->{session}->talk( { method => "test/path", params => { para1 => "v1", para2 => "v2" } } );
($name, $args) = $mock->next_call();
$url = @$args[1];
$opts = @$args[2];

is ($url, "https://api.themoviedb.org/3/test/path?para1=v1&para2=v2", "There is no API key in query-string parameters");
is ($opts->{headers}->{Authorization}, "Bearer fake-api-token", "Presence of Authorization header in HTTP options");

# Done
done_testing(4);
exit 0;
