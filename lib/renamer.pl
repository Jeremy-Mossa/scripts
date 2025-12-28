#!/usr/bin/env perl

use strict;
use warnings;
use 5.40.0; # version of perl
use utf8;
use autodie; # to handle errors
use Cwd qw(getcwd);


sub clean_filenames() {
  my $current_dir = getcwd();

  opendir( my $dh, $current_dir );
  while ( my $file = readdir($dh) ) {
    if ( $file =~ /^\./ )            { next; }
    if ( $file !~ /\.(opus|mp4)$/i ) { next; }

    my $new_name = $file;

    $new_name =~ s/'s/s/g;
    $new_name =~ s/\[[^]]*\]//g;
    $new_name =~ s/ \./\./g;
    $new_name =~ s/ +/ /g;
    $new_name =~ s/ - / /g;
    $new_name =~ s/- / /g;
    $new_name =~ s/ -/ /g;
    $new_name =~ s/, / /g;
    $new_name =~ s/[()]//g;
    $new_name =~ s/： /_/g;
    $new_name =~ s/ ｜ / /g;
    $new_name =~ s/\.{3}//g;
    $new_name =~ s/\. \. \. //g;
    $new_name =~ s/ \. \. \. //g;
    $new_name =~ s/\.\.\.opus/\.opus/g;
    $new_name =~ s/\.\.opus/\.opus/g;
    $new_name =~ s/\.{2}/\./g;
    $new_name =~ s/ \/\///g;
    $new_name =~ s/ ⧸⧸//g;
    $new_name =~ s/!!//g;
    $new_name =~ s/\s+(?=\.m)/ /g;
    $new_name =~ s/([^.])opus$/$1.opus/i;
    $new_name =~ s/([^.])mp4$/$1.mp4/i;
    $new_name =~ s/^\s+|\s+$//g;

    if ( $new_name ne $file ) {
      rename( "$current_dir/$file", "$current_dir/$new_name" )
        or warn "Rename failed: $file → $new_name : $!\n";
    }
  }
closedir($dh);

