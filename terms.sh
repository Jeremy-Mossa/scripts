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
      # this backgrounds a loop that move and maximize xterms
      (
        while ! xdotool search --name "XTerm WS$i" >/dev/null; do
        sleep 0.5
        done
        wmctrl -r "XTerm WS$i" -t $(($i - 1))
        wmctrl -r "XTerm WS$i" -b add,maximized_vert,maximized_horz
      ) &
  fi
done
