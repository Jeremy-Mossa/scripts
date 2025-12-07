#!/bin/sh

# vids.sh - List the latest x videos from each channel in channels.txt


# vids-audio.sh - Fetch latest videos, download new ones as high-quality Opus audio,
#                 and add downloaded URLs to ignore.txt

CHANNELS_FILE="$HOME/Documents/channels.txt"
IGNORE_FILE="$HOME/phone/ignore.txt"
MAX_ITEMS=10  # How many latest videos to consider per channel

# Create ignore file if missing
[ -f "$IGNORE_FILE" ] || touch "$IGNORE_FILE"

# Load ignored URLs into a variable (one per line)
IGNORED=$(cat "$IGNORE_FILE" 2>/dev/null || true)

if [ ! -f "$CHANNELS_FILE" ]; then
    echo "Error: $CHANNELS_FILE not found."
    exit 1
fi

while IFS= read -r channel || [ -n "$channel" ]; do
    # Skip empty lines and comments
    case "$channel" in "" | \#*) continue ;; esac

    echo ">> Processing: $channel"

    # Get the latest MAX_ITEMS videos (fast flat mode)
    yt-dlp --flat-playlist --playlist-reverse --playlist-items 1-"$MAX_ITEMS" \
           --skip-download --print "https://www.youtube.com/watch?v=%(id)s" \
           "$channel" 2>/dev/null |
    while IFS= read -r url; do
        # Skip if already downloaded
        if echo "$IGNORED" | grep -Fx "$url" >/dev/null; then
            echo "   Skipping (already downloaded): $url"
            continue
        fi

        echo "   Downloading audio: $url"

        # Download best audio as Opus
        if yt-dlp -f bestaudio --extract-audio --audio-format opus \
                  --output "%(title)s.%(ext)s" \
                  "$url"; then
            # On success, add URL to ignore list
            echo "$url" >> "$IGNORE_FILE"
            echo "   Added to ignore list."
        else
            echo "   Failed to download: $url"
        fi
    done

    echo
done < "$CHANNELS_FILE"

echo "All done. New audio files are in the current directory."
