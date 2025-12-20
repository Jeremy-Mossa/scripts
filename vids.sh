#!/bin/sh

# vids.sh - List the latest x videos from each channel in channels.txt

cd "$HOME/phone" || { echo "Error: Cannot change to $HOME/phone"; exit 1; }

CHANNELS_FILE="$HOME/Documents/channels.txt"
IGNORE_FILE="$HOME/Documents/ignore.txt"
MAX_ITEMS=10  # How many videos channel

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
            continue
        fi

        if echo "$channel" | grep -q "ThePrime" && echo "$title" | grep -qi "standup"; then
            continue
        fi

        # extract best audio as Opus
        if yt-dlp -f bestaudio --extract-audio --audio-format opus \
                  --output "%(title)s.%(ext)s" \
                  "$url"; then
            # On success, add URL to ignore list
            echo "$url" >> "$IGNORE_FILE"
        else
            echo "   Failed to download: $url"
        fi
    done

    echo
done < "$CHANNELS_FILE"

rm $HOME/phone/*Standup* 2>/dev/null
echo "All done. New audio files are in the current directory."
