#!/bin/sh

# List of Android vendor IDs
VENDOR_IDS="18d1 04e8 12d1 2717 22d9 2d95 \
  2a70 22b8 1004 054c 0bb4 0b05 17ef 19d2 1949 0489"

# Find matching device in lsusb
DEVICE=$(lsusb | grep -E "$(echo $VENDOR_IDS | tr ' ' '|')" | head -n1)

# Extract vendor, model, and IDs
if [ -n "$DEVICE" ]; then
    IDS=$(echo "$DEVICE" | cut -d' ' -f6)
    VENDOR_ID=$(echo "$IDS" | cut -d: -f1)
    PRODUCT_ID=$(echo "$IDS" | cut -d: -f2)
    VENDOR_MODEL=$(echo "$DEVICE" | cut -d' ' -f7-)
    VENDOR=$(echo "$VENDOR_MODEL" | cut -d' ' -f1-3)
    MODEL=$(echo "$VENDOR_MODEL" | cut -d' ' -f4-)
else
    VENDOR="Unknown"
    MODEL="Unknown"
    IDS="Unknown"
fi

# Display in xterm and pause
DISPLAY=:0 xterm -e "echo \
  'Android device found:'; \
  echo;
  echo '$VENDOR'; echo '$MODEL'; \
  echo 'Device ID: $IDS'; \
  echo;
  echo 'Press Enter to close'; read"
