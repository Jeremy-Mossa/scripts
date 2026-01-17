#!/usr/bin/perl

use strict;
use warnings;
use v5.40;
use utf8;
use autodie;

my $file_name;

if (@ARGV == 0) {
    die "Error: No file name provided. Usage: $0 <filename>\n";
}
$file_name = $ARGV[0];

# exit script if file_name is undefined, empty,
# only whitespace, or contains invalid characters
# /^\s*$/ matches 0 or more whitespace characters
# ^   is the start of line
# \s* is 0 or more whitespace characters
# $   is the end of line
# [...]+ contains the set of 1 or more (+) valid characters
if (not defined($file_name)) {
    die "Error: File name is undefined. Usage: $0 <filename>\n";
}
elsif ($file_name =~ /^\s*$/) {
    die "Error: File name empty or contains only whitespace.\n";
}
elsif ($file_name !~ /^[a-zA-Z0-9_-]+$/) {
    # 'file.pl' throws error. user must provide 'file' only
    die "Error: File name contains invalid characters. \n"
         . "Characters allowed: \'a-z A-Z 0-9 _ -\'\n";
}

# append .pl suffix
# perl uses '.=' for string concatenation
$file_name .= ".pl";

# check if file already exists
if (-e $file_name) {
    die "Error: File $file_name already exists\n";
}

open(my $fh, '>', $file_name);

# use a heredoc to write perl boilerplate into file_name.pl
print $fh <<'EOF';
#!/usr/bin/env perl

use 5.42.0; # version of perl
use utf8;
use strict;
use warnings;
use autodie; # to handle errors


EOF
close($fh);

# make file_name.pl executable
chmod(0755, $file_name);

# add to heredoc when needed
# use Data::Dumper;
# 
# # make Data::Dumper pretty-print
# $Data::Dumper::Terse = 1; # just dump data contents
# $Data::Dumper::Indent = 0; # single-line output
