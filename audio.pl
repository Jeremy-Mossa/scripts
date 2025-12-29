#!/usr/bin/env perl


use strict;
use warnings;
use 5.40.0;
use utf8;
use autodie;
use File::Basename;
use File::Spec;


# ----------------------------- CONFIGURATION -----------------------------
my $home = $ENV{HOME};
die "HOME environment variable not set\n" if !$home;

my $download_dir  = File::Spec->catdir( $home, "phone" );
my $videos_dir    = File::Spec->catdir( $home, "videos/yt" );
my $channels_file = File::Spec->catfile( $home, "Documents", "channels.txt" );
my $ignore_file   = File::Spec->catfile( $home, "Documents", "ignore.txt" );

my $max_audio_items = 10;

# ------------------------------------------------------------------------

# change to download directory
chdir($download_dir)
  or die "Error: Cannot change to $download_dir: $!\n";

# Create ignore file if it does not exist
if ( !-f $ignore_file ) {
    open my $fh, '>', $ignore_file;
    close $fh;
}

# Load ignored URLs into a hash
my %ignored_urls;
open my $fh_ignore, '<', $ignore_file;
while ( my $line = <$fh_ignore> ) {
    chomp $line;
    $ignored_urls{$line} = 1;
}
close $fh_ignore;

# --------------------------- CLEANER FUNCTION ---------------------------
sub clean_filenames() {
    my $current_dir = $ENV{PWD};

    opendir( my $dh, $current_dir );
    while ( my $file = readdir($dh) ) {
        if ( $file =~ /^\./ )            { next; }    # skip hidden
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
}
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
# No argument → download new audio from all channels in channels.txt
# ------------------------------------------------------------------------
if ( @ARGV == 0 ) {

    if ( !-f $channels_file ) {
        die "Error: $channels_file not found.\n";
    }

    open my $fh_channels, '<', $channels_file;

    while ( my $channel_line = <$fh_channels> ) {
        chomp $channel_line;

        if ( $channel_line =~ /^\s*$/ ) { next; }    # skip blank lines
        if ( $channel_line =~ /^\s*#/ ) { next; }    # skip comments

        my $handle = $channel_line;
        $handle =~ s{^.*(@)}{$1};                    # keep @handle
        $handle =~ s{/videos.*$}{};                  # remove /videos

        print "Processing: $handle\n";

        my $video_list_cmd =
            "yt-dlp "
          . "--flat-playlist "
          . "--playlist-reverse "
          . "--playlist-items 1-$max_audio_items "
          . "--skip-download "
          . "--print 'https://www.youtube.com/watch?v=%(id)s' "
          . "'$channel_line' "
          . "2>/dev/null";
        my @video_urls = split /\n/, `$video_list_cmd`;
        chomp @video_urls;

        for my $url (@video_urls) {

            if ( $ignored_urls{$url} ) { next; }    # already downloaded

            if ( $channel_line =~ /ThePrime/ ) {
                my $title = `yt-dlp --get-title "$url" 2>/dev/null`;
                chomp $title;
                if ( $title =~ /standup/i ) {
                    next;
                }
            }

            my $safe_url = $url;
            $safe_url =~ s/'/'\\''/g;               # escape single quotes
            my $cmd =
                "yt-dlp "
              . "-f bestaudio "
              . "--no-warnings "
              . "--quiet "
              . "--progress "
              . "--extract-audio "
              . "--audio-format opus "
              . "--output \"%(title)s.%(ext)s\" "
              . "'$safe_url'";

            if ( system($cmd) == 0 ) {
                $ignored_urls{$url} = 1;
                open my $fh_append, '>>', $ignore_file;
                print $fh_append "$url\n";
                close $fh_append;
            }
            else {
                warn "Failed to download: $url\n";
            }
        }

        print "\n";
    }

    close $fh_channels;

    clean_filenames();

    # Delete leftover standup files
    unlink glob("*[Ss]tandup*");

    print "All done. New audio files are in $download_dir\n";
}

# ------------------------------------------------------------------------
# One argument like @username → download 10 latest videos
# ------------------------------------------------------------------------
else {
    # change to videos/yt directory
    chdir($videos_dir)
        or die "Error: Cannot change to $download_dir: $!\n";

    if ( @ARGV != 1 ) {
        die "Bad usage. Good usage: $0 \@xyz\n";
    }
    if ( $ARGV[0] !~ /^@[\w.-]+$/ ) {
        die "Bad handle format. Example: $0 \@xyz\n";
    }

    my $handle  = $ARGV[0];
    my $url     = "https://www.youtube.com/$handle/videos";
    my $archive = "$handle-archive.txt";

    my @cmd = (
        'yt-dlp',
        '-f',
        'bestvideo[height<=1080]+bestaudio/best[height<=1080]',
        '--quiet',
        '--no-warnings',
        '--progress',
        '--progress-template',
        'download:Downloading: '
          . '%(info.title)s '
          . '[%(progress._percent_str)s'
          . '%(progress._speed_str)s '
          . 'ETA %(progress._eta_str)s ]',
        '--merge-output-format',
        'mp4',
        '--embed-thumbnail',
        '--add-metadata',
        '--download-archive',
        $archive,
        '--ignore-errors',
        '--playlist-items',
        '1:10',
        '--cookies-from-browser',
        'chromium',
        $url
    );

    system(@cmd) == 0
      or die "yt-dlp failed with exit code $?\n";

    clean_filenames();

    say "\nDone! Archive file: $archive (keeps track of downloaded videos)";
}
