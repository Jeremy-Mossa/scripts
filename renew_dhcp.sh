#!/bin/ksh
# POSIX-compliant ksh script to renew DHCP lease for connected network interface

# Function to find connected interface
find_connected_interface() {
    # Use ifconfig to list interfaces with an inet address
    /sbin/ifconfig | while read line; do
        # Check for interface name (lines starting with a word followed by colon)
        case "$line" in
            *:*)
                interface=$(echo "$line" | cut -d: -f1)
                ;;
            *inet\ *)
                # If line contains inet and interface is set, it's a candidate
                if [ -n "$interface" ]; then
                    # Skip loopback interface
                    if [ "$interface" != "lo" ]; then
                        # Prefer wireless interfaces (often start with 'w' or contain 'wl')
                        case "$interface" in
                            w* | wl*)
                                echo "$interface"
                                return 0
                                ;;
                        esac
                        # Store first non-wireless interface as fallback
                        if [ -z "$fallback" ]; then
                            fallback="$interface"
                        fi
                    fi
                fi
                ;;
        esac
    done

    # Return fallback interface if no wireless interface found
    if [ -n "$fallback" ]; then
        echo "$fallback"
        return 0
    fi

    # No connected interface found
    return 1
}

# Find the connected interface
INTERFACE=$(find_connected_interface)

# Check if an interface was found
if [ -n "$INTERFACE" ]; then
    # Release and renew DHCP lease using dhclient
    /usr/bin/sudo /sbin/dhclient -r "$INTERFACE" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        /usr/bin/sudo /sbin/dhclient "$INTERFACE" >/dev/null 2>&1
    fi
fi
