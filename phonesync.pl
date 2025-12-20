#!/usr/bin/env perl

use strict;
use warnings;
use 5.40.0; # version of perl
use utf8;
use autodie; # to handle errors
use Data::Dumper;

# make Data::Dumper pretty-print
$Data::Dumper::Terse = 1; # just dump data contents
$Data::Dumper::Indent = 0; # single-line output

my $adbstatus = `adb devices`;
chomp($adbstatus);
print "$adbstatus\n";
