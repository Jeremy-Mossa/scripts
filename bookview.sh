#!/bin/bash

sleep 2
window=$(xdotool search mupdf 2>/dev/null)
xdotool windowsize $window 965 1030
xdotool windowmove $window 953 0
