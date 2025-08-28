#!perl

####################
# LOAD CORE MODULES
####################
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;
use TMDB;

# Autoflush ON
local $| = 1;

# Test TMDB instance creation
ok (TMDB->new( apikey => 'fake-api-key'), 'Initialize without language');
ok (TMDB->new( apikey => 'fake-api-key', lang => 'en' ), 'Initialize with ISO 636-1 language code');
ok (TMDB->new( apikey => 'fake-api-key', lang => 'EN' ), 'Initialize with ISO 636-1 language code upercase');
ok (TMDB->new( apikey => 'fake-api-key', lang => 'en-US' ), 'Initialize with IETF language tag language');
dies_ok { TMDB->new( apikey => 'fake-api-key', lang => 'en-us' ) } 'country code part should be upercase';
dies_ok { TMDB->new( apikey => 'fake-api-key', lang => 'en-us' ) } 'language code part should be lovercase';
ok (!TMDB->new( apikey => 'fake-api-key')->session->_http_options->{headers}->{Authorization}, 'No Authorization header in HTTP options');
is (TMDB->new( apikey => 'fake-api-key')->session->apikey, 'fake-api-key', 'Session::apikey contains the api key');

# Test with access-token
ok (TMDB->new( token => 'fake-token'), 'Initialize with a token');
is (TMDB->new( token => 'fake-token')->session->_http_options->{headers}->{Authorization}, "Bearer fake-token", "Presence of Authorization header in HTTP options");
ok (!(TMDB->new( token => 'fake-token')->session->apikey), "No api key");

# Test with both api key and access token
dies_ok { TMDB->new( apikey => 'fake-api-key', token => 'fake-token' ) } 'Should not have an apikey and a token simultaneously';

# Test with api_key and empty access-token
ok (TMDB->new( apikey => 'fake-api-key', token => '' ), 'Initialize with api_key and empty access-token');
is (TMDB->new( apikey => 'fake-api-key', token => '' )->session->apikey, 'fake-api-key', 'Session::apikey contains the api key');
ok (!(TMDB->new( apikey => 'fake-api-key', token => '' )->session->_http_options->{headers}->{Authorization}), "No Bearer token in HTTP options");

# Test with access-token and empty api_key
ok (TMDB->new( apikey => '', token => 'fake-token' ), 'Initialize with empty api_key and access-token');
is (TMDB->new( apikey => '', token => 'fake-token' )->session->_http_options->{headers}->{Authorization}, "Bearer fake-token", "Presence of Authorization header in HTTP options");
ok (!(TMDB->new( apikey => '', token => 'fake-token' )->session->apikey), "No api key");

# Test without api key and without access-token
ok (TMDB->new( ), 'Initialize without api key and without access-token');
ok (!(TMDB->new( )->session->_http_options->{headers}->{Authorization}), "No Bearer token in HTTP options");
ok (!(TMDB->new( )->session->apikey), "No api key");

# Test with empty api_key and empty access-token
ok (TMDB->new( apikey => '', token => '' ), 'Initialize with empty api_key and empty access-token');
ok (!(TMDB->new( apikey => '', token => '' )->session->_http_options->{headers}->{Authorization}), "No Bearer token in HTTP options");
ok (!(TMDB->new( apikey => '', token => '' )->session->apikey), "No api key");

# Done
done_testing();
exit 0;
