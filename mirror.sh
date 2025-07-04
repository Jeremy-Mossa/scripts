#!/bin/ksh

# Check if script is already running
pid_file="/tmp/mirror.sh.pid"
if [ -f "$pid_file" ]; then
    old_pid=$(cat "$pid_file")
    if ps -p "$old_pid" > /dev/null 2>&1; then
        echo "Script is already running with PID $old_pid. Exiting."
        exit 1
    fi
fi
echo $$ > "$pid_file"

# Function to clean up all processes and files
cleanup() {
    echo "Cleaning up..."
    if [ -n "$scrcpy_pid" ]; then
        kill "$scrcpy_pid" 2>/dev/null
    fi
    pkill -P $$ 2>/dev/null
    pkill -f "adb logcat" 2>/dev/null
    pkill -f "scrot" 2>/dev/null
    pkill -f "python3.*match_template" 2>/dev/null
    adb kill-server 2>/dev/null
    rm -f "$HOME/pics/scrcpy_screenshot.png" "$HOME/pics/matched_area.png" "/tmp/autoplay_cooldown" "$pid_file"
    exit 0
}

# Set up trap for cleanup on exit
trap cleanup INT TERM EXIT

# Start adb server
adb start-server || { echo "Failed to start adb server"; exit 1; }

# Set Android device brightness to just above 0 (10/255)
adb shell settings put system screen_brightness 10 || { echo "Failed to set device brightness"; }

# Clear adb logs every 10 seconds in the background
(
    while true; do
        adb logcat -c >/dev/null 2>&1
        sleep 10
    done
) &

# Start scrcpy with specified settings
scrcpy --window-title="Android Automation" --max-size=800 --max-fps=10 --no-audio --window-borderless &

# Store scrcpy PID
scrcpy_pid=$!

# Wait for scrcpy window to open
echo "Waiting for scrcpy window..."
timeout=60
count=0
while [ $count -lt $timeout ]; do
    window_id=$(xdotool search --name "Android Automation" 2>/dev/null)
    if [ -n "$window_id" ]; then
        echo "Scrcpy window found with ID: $window_id"
        break
    fi
    # Fallback: try CPH2611
    window_id=$(xdotool search --name "CPH2611" 2>/dev/null)
    if [ -n "$window_id" ]; then
        echo "Scrcpy window found with ID: $window_id (using CPH2611 title)"
        break
    fi
    sleep 1
    count=$((count + 1))
done
if [ $count -eq $timeout ]; then
    echo "Error: Timeout waiting for scrcpy window"
    cleanup
fi

# Move scrcpy window to top-left (0,0) and ensure it’s mapped
xdotool windowmove "$window_id" 0 0 2>/dev/null
xdotool windowmap "$window_id" 2>/dev/null

# Function to perform a random click within boundaries
random_click() {
    x_min=$1
    y_min=$2
    x_max=$3
    y_max=$4
    window_id=$5
    button_name=$6
    
    # Generate random x within full x-range
    x=$((x_min + RANDOM % (x_max - x_min + 1)))
    
    # Generate random y: bottom 50% for autoplay, full range for replay
    height=$((y_max - y_min))
    if [ "$button_name" = "autoplay" ]; then
        y_start=$((y_min + height / 2))  # Start at middle of rectangle
        y_range=$((y_max - y_start + 1)) # Range from middle to bottom
        y=$((y_start + RANDOM % y_range))
    else
        y=$((y_min + RANDOM % (y_max - y_min + 1)))
    fi
    
    # Perform click using xdotool directly at the coordinates
    echo "Clicking $button_name at desktop ($x, $y)"
    xdotool mousemove "$x" "$y" click 1 2>/dev/null
}

# Search for buttons every 20 seconds in the background
(
    while true; do
        # Clean up previous screenshot and matched area
        rm -f "$HOME/pics/scrcpy_screenshot.png" "$HOME/pics/matched_area.png"
        
        # Find scrcpy window
        window_id=$(xdotool search --name "Android Automation" 2>/dev/null)
        if [ -z "$window_id" ]; then
            window_id=$(xdotool search --name "CPH2611" 2>/dev/null)
        fi
        if [ -z "$window_id" ]; then
            echo "Scrcpy window not found"
            sleep 20
            continue
        fi
        
        # Ensure window is mapped
        xdotool windowmap "$window_id" 2>/dev/null
        
        # Try capturing screenshot with retries
        retry_count=0
        max_retries=3
        while [ $retry_count -lt $max_retries ]; do
            xdotool windowraise "$window_id" 2>/dev/null
            scrot -u -b "$HOME/pics/scrcpy_screenshot.png" 2>/dev/null
            if [ -f "$HOME/pics/scrcpy_screenshot.png" ]; then
                echo "Screenshot captured"
                break
            fi
            echo "Failed to capture screenshot (attempt $((retry_count + 1))/$max_retries)"
            retry_count=$((retry_count + 1))
            sleep 2
        done
        if [ $retry_count -eq $max_retries ]; then
            echo "Giving up after $max_retries failed screenshot attempts"
            sleep 20
            continue
        fi
        
        # Check autoplay cooldown
        autoplay_search=1
        if [ -f "/tmp/autoplay_cooldown" ]; then
            last_click=$(cat "/tmp/autoplay_cooldown")
            current_time=$(date +%s)
            elapsed=$((current_time - last_click))
            if [ "$elapsed" -lt 1800 ]; then
                autoplay_search=0
                echo "Autoplay in cooldown (elapsed: $elapsed seconds, remaining: $((1800 - elapsed)) seconds)"
            fi
        fi
        
        # Python script for OpenCV template matching
        match_result=$(python3 -c '
import cv2
import numpy as np
import sys

# Load screenshot
screenshot = cv2.imread("'$HOME/pics/scrcpy_screenshot.png'")
if screenshot is None:
    print("Error: Could not load screenshot")
    sys.exit(1)

# Function to match template
def match_template(template_path, button_name):
    template = cv2.imread(template_path)
    if template is None:
        print(f"Error: Could not load {button_name}")
        return "No match"
    h, w = template.shape[:2]
    result = cv2.matchTemplate(screenshot, template, cv2.TM_CCOEFF_NORMED)
    min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)
    if max_val >= 0.7:
        top_left = max_loc
        bottom_right = (top_left[0] + w, top_left[1] + h)
        debug_img = screenshot.copy()
        cv2.rectangle(debug_img, top_left, bottom_right, (0, 255, 0), 2)
        cv2.imwrite("'$HOME/pics/matched_area.png'", debug_img)
        return f"{top_left[0]},{top_left[1]},{max_val},{button_name},{w},{h}"
    return f"No match, confidence={max_val}"

# Match replay.png
replay_result = match_template("'$HOME/pics/replay.png'", "replay")

# Match autoplay.png if not in cooldown
autoplay_result = "No match"
if '$autoplay_search':
    autoplay_result = match_template("'$HOME/pics/autoplay.png'", "autoplay")

# Output results
print(f"{replay_result};{autoplay_result}")
' 2>&1)
        
        if echo "$match_result" | grep -q "Error"; then
            echo "Template matching failed: $match_result"
            sleep 20
            continue
        fi
        
        # Process replay result
        replay_result=$(echo "$match_result" | cut -d';' -f1)
        if echo "$replay_result" | grep -q "No match"; then
            echo "$replay_result"
        else
            x=$(echo "$replay_result" | cut -d',' -f1)
            y=$(echo "$replay_result" | cut -d',' -f2)
            confidence=$(echo "$replay_result" | cut -d',' -f3)
            button_name=$(echo "$replay_result" | cut -d',' -f4)
            width=$(echo "$replay_result" | cut -d',' -f5)
            height=$(echo "$replay_result" | cut -d',' -f6)
            x_max=$((x + width))
            y_max=$((y + height))
            echo "Replay button found at ($x, $y), size ($width, $height), confidence=$confidence"
            echo "Saved matched area to $HOME/pics/matched_area.png"
            random_click $x $y $x_max $y_max "$window_id" "replay"
        fi
        
        # Process autoplay result
        autoplay_result=$(echo "$match_result" | cut -d';' -f2)
        if echo "$autoplay_result" | grep -q "No match"; then
            if [ "$autoplay_search" -eq 1 ]; then
                echo "$autoplay_result"
            fi
        else
            x=$(echo "$autoplay_result" | cut -d',' -f1)
            y=$(echo "$autoplay_result" | cut -d',' -f2)
            confidence=$(echo "$autoplay_result" | cut -d',' -f3)
            button_name=$(echo "$autoplay_result" | cut -d',' -f4)
            width=$(echo "$autoplay_result" | cut -d',' -f5)
            height=$(echo "$autoplay_result" | cut -d',' -f6)
            x_max=$((x + width))
            y_max=$((y + height))
            echo "Autoplay button found at ($x, $y), size ($width, $height), confidence=$confidence"
            echo "Saved matched area to $HOME/pics/matched_area.png"
            random_click $x $y $x_max $y_max "$window_id" "autoplay"
            date +%s > "/tmp/autoplay_cooldown"
        fi
        
        sleep 20
    done
) &

# Wait for scrcpy to exit
wait "$scrcpy_pid"
