package Renamer;

use strict;
use warnings;
use 5.40.0;
use utf8;
use autodie;
use Cwd qw(getcwd);
use Exporter 'import';  # this is how perl exports a sub
our @EXPORT_OK = qw(clean_filenames);  # export on request

sub clean_filenames {
    my $dir = @_ ? shift : getcwd();  # optional dir arg, default current
    opendir(my $dh, $dir);
    while (my $file = readdir($dh)) {
        if ($file =~ /^\./) { next; }
        if ($file !~ /\.(opus|mp4)$/i) { next; }
        my $new_name = $file;
        $new_name =~ s/'s/s/g;
        $new_name =~ s/\[[^]]*\]//g;
        $new_name =~ s/ \.opus/\.opus/g;
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
        $new_name =~ s/\. \. \. opus/\.opus/g;
        $new_name =~ s/ \. \. \. opus/\.opus/g;
        $new_name =~ s/\. \. \. //g;
        $new_name =~ s/ \. \. \. //g;
        $new_name =~ s/\.\.\.opus/\.opus/g;
        $new_name =~ s/ \.\.opus/\.opus/g;
        $new_name =~ s/\.\.opus/\.opus/g;
        $new_name =~ s/\.{2}/\./g;
        $new_name =~ s/ \/\///g;
        $new_name =~ s/ ⧸⧸//g;
        $new_name =~ s/!!//g;
        $new_name =~ s/\s+(?=\.m)/ /g;
        $new_name =~ s/([^.])opus$/$1.opus/i;
        $new_name =~ s/([^.])mp4$/$1.mp4/i;
        $new_name =~ s/^\s+|\s+$//g;
        if ($new_name ne $file) {
            rename("$dir/$file", "$dir/$new_name")
                or warn "Rename failed: $file → $new_name : $!\n";
        }
    }
    closedir($dh);
}

1;  # perl requires for modules to return true
