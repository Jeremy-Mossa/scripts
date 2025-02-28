#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 'your text here'"
    exit 1
fi

input_text="$1"

window_id=$(xdotool search grok | tail -n1)
xdotool windowactivate --sync "$window_id"

xdotool mousemove 400 970 click 1

xdotool type --delay 100 "$input_text"
xdotool key Return

sleep 5

xdotool key ctrl+a
xdotool key ctrl+c

echo -n "\n$input_text\n" >> response.txt
xclip -o -selection clipboard >> response.txt

echo "=== Copilot Response ==="
echo "-----------------------"
cat response.txt | fold -w 80 -s | sed 's/^/| /'
echo "-----------------------"
