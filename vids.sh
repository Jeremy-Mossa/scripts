#!/bin/sh

# vids.sh - List the latest x videos from each channel in channels.txt

CHANNELS_FILE="$HOME/Documents/channels.txt"

if [ ! -f "$CHANNELS_FILE" ]; then
    echo "Error: $CHANNELS_FILE not found in current directory."
    exit 1
fi

while IFS= read -r url || [ -n "$url" ]; do
    # Skip empty lines and comments
    case "$url" in
        "" | \#*) continue ;;
    esac

    echo ">> $url"

    yt-dlp --flat-playlist --playlist-reverse \
           --playlist-items 1-5 \
           --skip-download \
           --print "%(title)s https://www.youtube.com/watch?v=%(id)s" \
           "$url" 2>/dev/null || echo "Failed to fetch $url"

    echo
done < "$CHANNELS_FILE"
