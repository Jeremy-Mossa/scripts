#!/bin/ksh

# Check if script is already running
pid_file="/tmp/mirror.sh.pid"
if [ -f "$pid_file" ]; then
    old_pid=$(cat "$pid_file")
    if ps -p "$old_pid" >/dev/null 2>&1; then
        echo "Script is already running with PID $old_pid. Exiting."
        exit 1
    fi
fi
echo $$ > "$pid_file"

# AVG_CLICK: count=33 sum=69275

# Function to clean up all processes and files
cleanup() {
    echo "Cleaning up..."
    if [ -n "$scrcpy_pid" ]; then
        kill "$scrcpy_pid" 2>/dev/null
    fi
    if [ -n "$xvfb_pid" ]; then
        kill "$xvfb_pid" 2>/dev/null
    fi
    pkill -P $$ 2>/dev/null
    pkill -f "adb logcat" 2>/dev/null
    pkill -f "python3.*match_template" 2>/dev/null
    adb -s 6433f574 kill-server 2>/dev/null
    rm -f "$HOME/pics/scrcpy_screenshot.png" \
      "$HOME/pics/matched_area.png" \
      "$HOME/tmp/tmp.png" \
      "$pid_file"
    unset last_autoplay_time
    exit 0
}

# Set up trap for cleanup on exit
trap cleanup INT TERM EXIT

# Start adb server
adb -s 6433f574 start-server || { echo "Failed to start adb server"; exit 1; }

# Set Android device brightness to just above 0 (10/255)
adb -s 6433f574 shell settings put system screen_brightness 10 \
  || { echo "Failed to set device brightness"; }

# Clear adb logs every 10 seconds in the background
(
    while true; do
        adb -s 6433f574 logcat -c >/dev/null 2>&1
        sleep 10
    done
) &

# Start Xvfb
Xvfb :99 -screen 0 800x1280x24 >/dev/null 2>&1 &
xvfb_pid=$!
sleep 1  # Wait for Xvfb to start
if ! ps -p "$xvfb_pid" > /dev/null; then
    echo "Failed to start Xvfb"
    cleanup
fi
export DISPLAY=:99

# Start scrcpy with specified settings
scrcpy --window-title="Android Automation" \
  --max-size=800 --max-fps=10 \
  --no-audio --window-borderless \
  --select-usb &
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

# Move window to (0,0)
xdotool windowmove "$window_id" 0 0 2>/dev/null

# Function to perform a random click using xdotool on absolute screen coordinates
random_click() {
    x_min=$1
    y_min=$2
    x_max=$3
    y_max=$4
    button_name=$5
    
    # Generate random coordinates
    x=$((x_min + RANDOM % (x_max - x_min + 1)))
    y=$((y_min + RANDOM % (y_max - y_min + 1)))
    
    # Click at absolute screen coordinates
    echo "Clicking $button_name at screen ($x, $y)"
    xdotool mousemove --sync "$x" "$y" click 1 2>/dev/null
}

# Search for buttons every 20 seconds and save screenshot every minute
(
    last_tmp_screenshot=0
    while true; do
        # Clean up previous bootup screenshots
        rm -f "$HOME/tmp/tmp1.png" "$HOME/tmp/tmp2.png" "$HOME/tmp/tmp3.png"
        
        # Clean up previous screenshot and matched area
        rm -f "$HOME/pics/scrcpy_screenshot.png" "$HOME/pics/matched_area.png"
        
        # Ensure scrcpy window exists
        window_id=$(xdotool search --name "Android Automation" 2>/dev/null)
        if [ -z "$window_id" ]; then
            window_id=$(xdotool search --name "CPH2611" 2>/dev/null)
        fi
        if [ -z "$window_id" ]; then
            echo "Scrcpy window not found"
            sleep 20
            continue
        fi
        
        # Capture entire Xvfb screen using scrot
        retry_count=0
        max_retries=3
        while [ $retry_count -lt $max_retries ]; do
            if scrot "$HOME/pics/scrcpy_screenshot.png" 2>/dev/null; then
                break
            fi
            echo "Failed to capture screenshot (attempt $((retry_count + 1))/$max_retries)"
            retry_count=$((retry_count + 1))
            sleep 1
        done
        if [ $retry_count -eq $max_retries ]; then
            echo "Giving up after $max_retries failed screenshot attempts"
            sleep 20
            continue
        fi
        
        # Save screenshot to ~/tmp/tmp.png every minute
        current_time=$(date +%s)
        if [ $((current_time - last_tmp_screenshot)) -ge 60 ]; then
            cp "$HOME/pics/scrcpy_screenshot.png" "$HOME/tmp/tmp.png"
            last_tmp_screenshot=$current_time
        fi
        
        # Python script for OpenCV template matching
        match_result=$(python3 -c "
import cv2
import numpy as np
import sys

# Load screenshot
screenshot = cv2.imread('$HOME/pics/scrcpy_screenshot.png')
if screenshot is None:
    print('Error: Could not load screenshot')
    sys.exit(1)

# Function to match template
def match_template(template_path, button_name):
    template = cv2.imread(template_path)
    if template is None:
        print(f'Error: Could not load {button_name}')
        return 'No match'
    h, w = template.shape[:2]
    result = cv2.matchTemplate(screenshot, template, cv2.TM_CCOEFF_NORMED)
    min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)
    if max_val >= 0.85:
        top_left = max_loc
        bottom_right = (top_left[0] + w, top_left[1] + h)
        debug_img = screenshot.copy()
        cv2.rectangle(debug_img, top_left, bottom_right, (0, 255, 0), 2)
        cv2.imwrite('$HOME/pics/matched_area.png', debug_img)
        return f'{top_left[0]},{top_left[1]},{max_val},{button_name},{w},{h}'
    return 'No match'

# Match replay.png
replay_result = match_template('$HOME/pics/replay.png', 'replay')

# Match ws.png and autoplay.png
ws_result = match_template('$HOME/pics/ws.png', 'ws')
autoplay_result = match_template('$HOME/pics/autoplay.png', 'autoplay')

# Output results
print(f'{replay_result};{ws_result};{autoplay_result}')
" 2>&1)
        
        if echo "$match_result" | grep -q "Error"; then
            echo "Template matching failed: $match_result"
            sleep 20
            continue
        fi
        
        # Process replay result
        replay_result=$(echo "$match_result" | cut -d';' -f1)
        if echo "$replay_result" | grep -q "No match"; then
          :
        else
            x=$(echo "$replay_result" | cut -d',' -f1)
            y=$(echo "$replay_result" | cut -d',' -f2)
            confidence=$(echo "$replay_result" | cut -d',' -f3)
            button_name=$(echo "$replay_result" | cut -d',' -f4)
            width=$(echo "$replay_result" | cut -d',' -f5)
            height=$(echo "$replay_result" | cut -d',' -f6)
            x_max=$((x + width))
            y_max=$((y + height))
            echo -n "Replay button found at ($x, $y) "
            random_click $x $y $x_max $y_max "replay"
        fi

        # Process ws and autoplay results
        ws_result=$(echo "$match_result" | cut -d';' -f2)
        autoplay_result=$(echo "$match_result" | cut -d';' -f3)
        if echo "$ws_result" | grep -q "No match" || echo "$autoplay_result" | grep -q "No match"; then
            :
        else
            x=$(echo "$autoplay_result" | cut -d',' -f1)
            y=$(echo "$autoplay_result" | cut -d',' -f2)
            confidence=$(echo "$autoplay_result" | cut -d',' -f3)
            button_name=$(echo "$autoplay_result" | cut -d',' -f4)
            width=$(echo "$autoplay_result" | cut -d',' -f5)
            height=$(echo "$autoplay_result" | cut -d',' -f6)
            x_max=$((x + width))
            y_max=$((y + height))
            echo -n "Autoplay button found at ($x, $y) with ws present "
            random_click $x $y $x_max $y_max "autoplay"
            autoplay_time=$(date +%s)
            if [ -n "$last_autoplay_time" ]; then
                time_diff=$((autoplay_time - last_autoplay_time))
                if [ $time_diff -ge 1740 ] && [ $time_diff -le 2400 ]; then
                    avg_line=$(grep "^# AVG_CLICK:" "$0")
                    count=$(echo "$avg_line" | sed 's/.*count=\([0-9]*\).*/\1/')
                    sum=$(echo "$avg_line" | sed 's/.*sum=\([0-9]*\).*/\1/')
                    count=$((count + 1))
                    sum=$((sum + time_diff))
                    average=$((sum / count))
                    minutes=$((average / 60))
                    seconds=$((average % 60))
                    # Update the script's comment with count and sum
                    sed -i "s/^# AVG_CLICK:.*/# AVG_CLICK: count=$count sum=$sum/" "$0"
                    # Display time_diff and average in minutes:seconds
                    printf "Autoplay cycle time: %d:%02d, Average: %d:%02d\n" \
                        $((time_diff / 60)) $((time_diff % 60)) $minutes $seconds
                else
                    echo "Autoplay cycle time $time_diff seconds ignored (out of 1200-3000 range)"
                fi
            fi
            last_autoplay_time=$autoplay_time
        fi

        sleep 20
    done
) &

# Wait for scrcpy to exit
wait "$scrcpy_pid"
