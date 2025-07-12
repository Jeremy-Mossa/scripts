#!/bin/sh


# Get grok on WS 1
if ! wmctrl -l | grep -q "GROK"; then
  /bin/chromium-browser --window-name="GROK" \
    https://grok.com >/dev/null 2>&1 &
  disown
  sleep 2
  wmctrl -r "GROK" -t 0
fi

# Maximized xterm on WS 2
if ! xdotool search --name "XTerm WS2"; then
    xterm -T "XTerm WS2" &
    sleep 1
    wmctrl -r "XTerm WS2" -t 1
    wmctrl -r "XTerm WS2" -b add,maximized_vert,maximized_horz
fi

# Maximized xterm on WS 3
if ! xdotool search --name "XTerm WS3"; then
    xterm -T "XTerm WS3" &
    sleep 1
    wmctrl -r "XTerm WS3" -t 2
    wmctrl -r "XTerm WS3" -b add,maximized_vert,maximized_horz
fi

# Maximized xterm on WS 4
if ! xdotool search --name "XTerm WS4"; then
    xterm -T "XTerm WS4" &
    sleep 1
    wmctrl -r "XTerm WS4" -t 3
    wmctrl -r "XTerm WS4" -b add,maximized_vert,maximized_horz
fi

# Get Line app running on WS 5
if ! wmctrl -l | grep -q "LINE"; then
  chromium-browser --no-first-run \
    --new-window --window-name="LINE" \
    about:blank >/dev/null 2>&1 &
  sleep 1
  wmctrl -s 4
  wmctrl -r "LINE" -t 4
  sleep 3
  xdotool mousemove 1737 58
  xdotool click 1
  sleep 3
  xdotool mousemove 721 557
  xdotool click 1
  xdotool type $(cat $HOME/.ssh/line_password)
  sleep 0.5
  xdotool mousemove 800 606
  xdotool click 1
  disown
fi

# Get btop on WS 6
if ! xdotool search --name "btop"; then
    xterm -T "btop" -e btop &
    sleep 1
    wmctrl -r "btop" -t 5
    wmctrl -r "btop" -b add,maximized_vert,maximized_horz
fi
