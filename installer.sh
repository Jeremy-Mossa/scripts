#!/bin/bash

# Define the file containing the list of programs to install
INSTALL_LIST=~/Documents/to_install.txt

# Check if the install list file exists
if [ ! -f "$INSTALL_LIST" ]; then
    echo "Error: File $INSTALL_LIST does not exist."
    exit 1
fi

# Function to install a single program
install_program() {
    local program=$1
    echo "Installing $program..."

    if command -v "$program" >/dev/null 2>&1; then
        echo "$program is already installed."
    else
        # Attempt to install the program using dnf, the package manager for Fedora
        sudo dnf install -y "$program"

        # Check if the installation was successful
        if command -v "$program" >/dev/null 2>&1; then
            echo "$program has been installed successfully."
        else
            echo "Error: Failed to install $program."
            return 1
        fi
    fi

    return 0
}

# Elevate privileges at the start
sudo -v

# Read the install list file line by line
while IFS= read -r program; do
    # Skip empty lines and comments
    if [[ -z "$program" || "$program" == \#* ]]; then
        continue
    fi

    install_program "$program"
done < "$INSTALL_LIST"

echo "All programs processed."
