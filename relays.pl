#!/usr/bin/perl

use warnings;
use v5.40;
use utf8;
use autodie;

`mullvad relay list > tmp.txt`;
open my $fh, '<', 'tmp.txt'
  or die "Cannot open file: $!";
local $/;

my $relays = <$fh>;
my @relays = split(/\n/, $relays);
close($fh); 
`rm tmp.txt`;

my @hops;
foreach my $line (@relays)
{
  if ($line =~ /(se-|ch-|fi-)/ &&
      $line =~ /([a-z]{2}-[a-z]{2,3}-[a-z]{2,4}-[0-9]{3})/)
  {
    push @hops, $1;
  }
}

srand;
my $max = 105;
my $hop = int(rand($max));

`mullvad disconnect`;
`mullvad relay set location $hops[$hop]`;
`mullvad connect`;
