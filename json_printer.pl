#!/usr/bin/perl

use warnings;
use v5.40;
use utf8;
use autodie;
use JSON::PP;

open my $fh, '<', '/home/jbm/tmp/data.json' 
  or die "Cannot open file: $!";

my @lines;
while (my $line = <$fh>) {
    push @lines, $line if $. >= 6 && $. <= 8;
}

close $fh;

system('rm /home/jbm/tmp/data.json');

my $json_text = join '', @lines;

my $json_parser = JSON::PP->new->utf8;
my $data = $json_parser->decode($json_text);
my $text_content = $data->{text};

print "\n$text_content\n";
