#!/usr/bin/env perl

use 5.42.0; # version of perl
use utf8;
use Carp qw/croak/;
use Mojo::DOM;
use Mojo::File;  # For reading files easily


#--------------------------- Internet check ----------------------------

# idle until connected to internet
while (1) {
  if (system('ping -c 1 ddg.gg >/dev/null') != 0) {
    sleep 60;
  }
  else { last; }
}

#-----------------------------------------------------------------------


#------------------------------- Config --------------------------------

# Orange ANSI color code
my $orange = "\e[38;5;208m";
my $reset  = "\e[0m";

# cache results for instant lookup later
my $cache_file = "/home/jbm/Documents/ticker_cache";

my $cache = '';
my $url = 'https://stooq.com/q/?s=';

# tickers for stooq.com queries
my @tickers = (
  'bito',
  'divo',
  'gain',
  'jepq',
  'main',
  'oxlc',
  'pflt',
);

#-----------------------------------------------------------------------


#----------------------- Functions (subroutines) -----------------------

sub cache_prices($ticker) {

  # Capture output from curl
  system("curl --silent -o $ticker.txt $url$ticker.us");

  # Load HTML from text file
  my $html = Mojo::File->new("$ticker.txt")->slurp;
  unlink "$ticker.txt";

  # Parse the HTML
  my $dom   = Mojo::DOM->new($html);
  my $price = $dom->at('span#aq_' . $ticker . '\.us_c4');
  say "$price";
  $price    = $price->text;
  say "$price";
  
  # truncate fractional pennies, left-pad price
  $price = sprintf("%.2f", $price);
  $price = sprintf("%6s", $price);

  # right-pad ticker: e.g. 'main' and 'dx  ' 
  $ticker = sprintf("%-4s", $ticker);

  if ($price) {
      $cache .= "$ticker: " . $price . "\n";
  }
  else {
      croak "no price found for $ticker";
  }
  
}

sub update_cache() {
  foreach my $ticker (@tickers) {
    cache_prices($ticker);
  }

  open(my $fh_writer, '>', $cache_file)
    or croak "Can't open $cache_file $!";

  # error handling here ensures data is immediately flushed
  print $fh_writer $cache
    or croak "Can't write to $cache_file: $!";

  close $fh_writer
}

sub print_cache() {

  open(my $fh_reader, '<', $cache_file) 
    or croak "Can't open $cache_file $!";

  print $orange;  # start orange color
  while (my $line = <$fh_reader>) {  # Angle brackets read a line
      print "\t$line";
  }
  print $reset;  # reset color at end

  close $fh_reader;
}

#-----------------------------------------------------------------------


#-------------------------------- Main ---------------------------------

if (@ARGV && $ARGV[0] eq '--update-only') {
  update_cache();
  exit;
}
else { print_cache(); }

#-----------------------------------------------------------------------
