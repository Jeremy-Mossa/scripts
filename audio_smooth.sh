#!/bin/sh

# Check if exactly one argument (input file) is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input.mp4>" >&2
    exit 1
fi

# Check if the input file exists
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found" >&2
    exit 1
fi

# Check if the input file has .mp4 extension
case "$1" in
    *.mp4) ;;
    *) echo "Error: Input file must be an .mp4 file" >&2; exit 1 ;;
esac

# Check if ffmpeg is installed
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg is not installed. Install it with 'sudo dnf install ffmpeg'" >&2
    exit 1
fi

# Check if file is writable
if [ ! -w "$1" ]; then
    echo "Error: File '$1' is not writable" >&2
    exit 1
fi

# Create a temporary file for processing
tempfile=$(mktemp /tmp/audio_smooth.XXXXXX.mp4) || {
    echo "Error: Failed to create temporary file" >&2
    exit 1
}

# Create a log file for FFmpeg output
logfile="/tmp/audio_smooth_$$.log"

# Apply audio filters: highpass for plosives, lowpass for squeals, afftdn for scratches, compand for volume smoothing
# Log FFmpeg output for debugging
if ffmpeg -i "$1" -af "highpass=f=200,lowpass=f=3000,afftdn=nr=10:nt=w:om=o,compand=attacks=0.3:decays=0.8:points=-70/-70|-20/-20|0/-10" -c:v copy -y "$tempfile" >"$logfile" 2>&1; then
    # Move temporary file to original file, overwriting it
    if mv "$tempfile" "$1"; then
        echo "Successfully processed '$1'"
        rm -f "$logfile"
    else
        echo "Error: Failed to overwrite '$1'" >&2
        rm -f "$tempfile" "$logfile"
        exit 1
    fi
else
    echo "Error: FFmpeg processing failed. Check '$logfile' for details" >&2
    rm -f "$tempfile"
    exit 1
fi

exit 0
