#!/bin/sh


# Maximized xterm windows on workspaces 2 - 6
for i in `seq 2 6`; do
  if ! xdotool search --name "XTerm WS$i"; then
      # btop to run on WS6
      if [ $i -eq 6 ]; then
        xterm -T "XTerm WS$i" -e btop &
      else 
        xterm -T "XTerm WS$i" &
      fi
      
      sleep 0.1
      wmctrl -r "XTerm WS$i" -t $(($i - 1))
      wmctrl -r "XTerm WS$i" -b add,maximized_vert,maximized_horz
  fi
done

# Get grok on WS 1
if ! wmctrl -l | grep -q "GROK"; then
  rm $HOME/.config/chromium/SingletonLock >/dev/null 2>&1
  /bin/chromium-browser --window-name="GROK" \
    https://grok.com >/dev/null 2>&1 &
  disown
  sleep 2
  wmctrl -r "GROK" -t 0
fi

# Get Line app running on WS 5
# if ! wmctrl -l | grep -q "LINE"; then
#   chromium-browser --no-first-run \
#     --new-window --window-name="LINE" \
#     about:blank >/dev/null 2>&1 &
#   sleep 1
#   wmctrl -s 4
#   wmctrl -r "LINE" -t 4
#   sleep 3
#   xdotool mousemove 1737 58
#   xdotool click 1
#   sleep 3
#   xdotool mousemove 721 557
#   xdotool click 1
#   xdotool type $(cat $HOME/.ssh/line_password)
#   sleep 0.5
#   xdotool mousemove 800 606
#   xdotool click 1
#   disown
# fi
