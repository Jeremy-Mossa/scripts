#!/bin/ksh

# Check if script is already running
if [ -f /tmp/mirror.sh.pid ]; then
    old_pid=$(cat /tmp/mirror.sh.pid)
    if ps -p "$old_pid" > /dev/null; then
        echo "Script is already running with PID $old_pid. Exiting."
        exit 1
    fi
fi

# Store current PID
echo $$ > /tmp/mirror.sh.pid

# Function to clean up all processes
cleanup() {
    # Kill scrcpy and its child processes
    if [ -n "$scrcpy_pid" ]; then
        kill "$scrcpy_pid" 2>/dev/null
    fi
    
    # Kill background loops and related processes
    pkill -P $$ 2>/dev/null
    pkill -f "adb logcat" 2>/dev/null
    pkill -f "import" 2>/dev/null
    pkill -f "compare" 2>/dev/null
    adb kill-server 2>/dev/null
    
    # Clean up screenshot and PID file
    rm -f ~/pics/scrcpy_screenshot.png
    rm -f /tmp/mirror.sh.pid
    
    exit 0
}

# Set up trap for cleanup on exit
trap cleanup INT TERM EXIT

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
scrcpy --max-size=720 --max-fps=10 --no-audio &

# Store scrcpy PID
scrcpy_pid=$!

# Wait for scrcpy window to open
sleep 5

# Raise scrcpy window (titled "CPH2611") initially
xdotool search --name "CPH2611" windowraise

# Function to perform a random click within boundaries
random_click() {
    x_min=$1
    y_min=$2
    x_max=$3
    y_max=$4
    window_id=$5
    
    # Generate random x and y within boundaries
    x=$((x_min + RANDOM % (x_max - x_min + 1)))
    y=$((y_min + RANDOM % (y_max - y_min + 1)))
    
    # Get window geometry (position on desktop)
    geometry=$(xdotool getwindowgeometry --shell "$window_id")
    win_x=$(echo "$geometry" | grep X= | cut -d= -f2)
    win_y=$(echo "$geometry" | grep Y= | cut -d= -f2)
    
    # Adjust coordinates to desktop (add window position)
    desktop_x=$((win_x + x))
    desktop_y=$((win_y + y))
    
    # Perform click using xdotool
    echo "Clicking at desktop ($desktop_x, $desktop_y) for window-relative ($x, $y)"
    xdotool mousemove "$desktop_x" "$desktop_y" click 1
}

# Search for button every 20 seconds in the background
(
    while true; do
        # Clean up previous screenshot
        rm -f ~/pics/scrcpy_screenshot.png
        
        # Find scrcpy window
        window_id=$(xdotool search --name "CPH2611")
        if [ -n "$window_id" ]; then
            # Capture window using ImageMagick import (works on non-visible windows)
            import -window "$window_id" ~/pics/scrcpy_screenshot.png
            if [ -f ~/pics/scrcpy_screenshot.png ]; then
                echo "Screenshot captured"
                
                # Use ImageMagick compare with 25% fuzz for 95% similarity
                match=$(compare -metric AE -fuzz 5% -subimage-search ~/pics/scrcpy_screenshot.png ~/pics/replay.png null: 2>&1 | grep -o '[0-9]*,[0-9]*')
                
                if [ -n "$match" ]; then
                    # Extract x,y coordinates
                    x=$(echo "$match" | cut -d',' -f1)
                    y=$(echo "$match" | cut -d',' -f2)
                    
                    # Get button dimensions from replay.png
                    button_size=$(identify -format "%w,%h" ~/pics/replay.png)
                    width=$(echo "$button_size" | cut -d',' -f1)
                    height=$(echo "$button_size" | cut -d',' -f2)
                    
                    # Calculate boundaries
                    x_max=$((x + width))
                    y_max=$((y + height))
                    
                    # Perform random click
                    echo "Button found at ($x, $y), size ($width, $height)"
                    random_click $x $y $x_max $y_max "$window_id"
                else
                    echo "No button match found"
                fi
            else
                echo "Failed to capture screenshot"
            fi
        else
            echo "Scrcpy window not found"
        fi
        
        sleep 20
    done
) &

# Wait for scrcpy to exit
wait "$scrcpy_pid"
