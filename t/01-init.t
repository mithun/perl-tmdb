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

# Test with access-token
ok (TMDB->new( token => 'fake-token'), 'Initialize with a token');
is (TMDB->new( token => 'fake-token')->session->_http_options->{headers}->{Authorization}, "Bearer fake-token", "Presence of Authorization header in HTTP options");
dies_ok { TMDB->new( apikey => 'fake-api-key', token => 'fake-token' ) } 'Should not have an apikey and a token simultaneously';

# Done
done_testing();
exit 0;
