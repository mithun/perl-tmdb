#!/usr/bin/perl

#####################
# LOAD CORE MODULES
#####################
use strict;
use warnings;
use Test::More;

# Autoflush
$| = 1;

# What are we testing?
my $module = "TMDB";

# Check loading
use_ok($module) or BAIL_OUT("Failed to load $module. Pointless to continue");

done_testing();
