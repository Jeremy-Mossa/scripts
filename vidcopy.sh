#!/bin/ksh

# Check if adb is installed
if ! command -v adb >/dev/null 2>&1; then
    echo "Error: adb not found. Please install Android Debug Bridge."
    exit 1
fi

# Check if exactly one device is connected
device_count=$(adb devices | grep -c device$)
if [ "$device_count" -ne 1 ]; then
    echo "Error: Please ensure exactly one Android device is connected."
    echo "Found $device_count devices."
    exit 1
fi

# Destination directory on Linux machine (current directory by default)
dest_dir="/home/jbm/mcoc/"

# Android home directory (usually /sdcard or /storage/emulated/0)
android_home="/storage/emulated/0/"

# Get list of v*.mp4 files
files=$(adb shell "ls $android_home/v*.mp4" 2>/dev/null)

# Check if any files were found
if [ -z "$files" ]; then
    echo "No v*.mp4 files found in $android_home"
    exit 0
fi

# Copy each file
for file in $files; do
    # Clean up filename (remove carriage returns if any)
    file=$(echo "$file" | tr -d '\r')
    
    # Extract basename for destination
    basename=$(echo "$file" | sed 's|.*/||')
    
    adb pull "$file" "$dest_dir/$basename"
    if [ $? -eq 0 ]; then
        echo "Successfully copied $basename"
    else
        echo "Failed to copy $basename"
    fi
done

exit 0
