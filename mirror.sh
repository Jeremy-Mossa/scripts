#!/bin/ksh

# Start adb server
adb start-server

# Clear adb logs every 10 seconds in the background
(
    while true; do
        adb logcat -c >/dev/null 2>&1
        sleep 10
    done
) &

# Start scrcpy with specified settings
# --max-fps=10 for 10 frames refresh
# --no-audio to disable sound
scrcpy --max-size=720 --max-fps=10 --no-audio &

# Store scrcpy PID
scrcpy_pid=$!

# Function to perform a random click within boundaries
random_click() {
    local x_min=$1
    local y_min=$2
    local x_max=$3
    local y_max=$4
    
    # Generate random x and y within boundaries
    local x=$((x_min + RANDOM % (x_max - x_min + 1)))
    local y=$((y_min + RANDOM % (y_max - y_min + 1)))
    
    # Perform the click using adb
    adb shell input tap $x $y
}

# Search for button every 20 seconds in the background
(
    while true; do
        # Capture scrcpy window (adjust window title if needed)
        scrot -u -b ~/pics/scrcpy_screenshot.png
        
        # Use ImageMagick compare to find replay.png in screenshot
        # Output format: x,y,width,height
        match=$(compare -metric AE -subimage-search ~/pics/scrcpy_screenshot.png ~/pics/replay.png null: 2>&1 | grep -o '[0-9]*,[0-9]*')
        
        if [ -n "$match" ]; then
            # Extract x,y coordinates
            x=$(echo "$match" | cut -d',' -f1)
            y=$(echo "$match" | cut -d',' -f2)
            
            # Get button dimensions from button.png
            button_size=$(identify -format "%w,%h" ~/pics/replay.png)
            width=$(echo "$button_size" | cut -d',' -f1)
            height=$(echo "$button_size" | cut -d',' -f2)
            
            # Calculate boundaries
            x_max=$((x + width))
            y_max=$((y + height))
            
            # Perform random click within button boundaries
            random_click $x $y $x_max $y_max
        fi
        
        # Clean up screenshot
        rm -f ~/pics/scrcpy_screenshot.png
        
        sleep 20
    done
) &

# Trap signals to clean up
trap 'kill "$scrcpy_pid" 2>/dev/null; killall scrot compare 2>/dev/null; exit 0' INT TERM

# Wait for scrcpy to exit
wait "$scrcpy_pid"
