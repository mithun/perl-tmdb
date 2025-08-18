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

TODO: {
    todo_skip "Not implemented: mithun/perl-tmdb#12", 1;

    ok (TMDB->new( apikey => 'fake-api-key', lang => 'en-US' ), 'Initialize with IETF language tag language');
};

dies_ok { TMDB->new( apikey => 'fake-api-key', lang => 'en-us' ) } 'country code part should be upercase';
dies_ok { TMDB->new( apikey => 'fake-api-key', lang => 'en-us' ) } 'language code part should be lovercase';


# Done
done_testing();
exit 0;
