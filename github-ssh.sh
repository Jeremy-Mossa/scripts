#!/bin/bash

# Configuration
EMAIL="jeremy.mossa@gmail.com"
GITHUB_USERNAME="Jeremy-Mossa"
SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# Function to check if a program is installed
check_program() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "$1 is not installed. Installing $1..."
        install_program "$1"
    else
        echo "$1 is already installed."
    fi
}

# Function to determine the package manager and install a program
install_program() {
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y "$1"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "$1"
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y "$1"
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y "$1"
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Syu --noconfirm "$1"
    elif command -v brew >/dev/null 2>&1; then
        brew install "$1"
    else
        echo "Error: Package manager not found. Please install $1 manually."
        exit 1
    fi
}

# Function to check for necessary dependencies
check_dependencies() {
    local dependencies=("ssh-keygen" "xclip" "ssh" "git")
    for program in "${dependencies[@]}"; do
        check_program "$program"
    done
}

# Function to generate SSH key
generate_ssh_key() {
    if [ -f "$SSH_KEY_PATH" ]; then
        echo "SSH key already exists."
    else
        ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f "$SSH_KEY_PATH" -N "" || {
            echo "Error: Failed to generate SSH key."
            exit 1
        }
        echo "SSH key generated."
    fi
}

# Function to add SSH key to ssh-agent
add_ssh_key_to_agent() {
    eval "$(ssh-agent -s)" || {
        echo "Error: Failed to start ssh-agent."
        exit 1
    }
    ssh-add "$SSH_KEY_PATH" || {
        echo "Error: Failed to add SSH key to ssh-agent."
        exit 1
    }
}

# Function to copy SSH key to clipboard
copy_ssh_key_to_clipboard() {
    xclip -selection clipboard < "${SSH_KEY_PATH}.pub" || {
        echo "Error: Failed to copy SSH key to clipboard."
        exit 1
    }
    echo "SSH key copied to clipboard."
}

# Function to add GitHub's SSH key fingerprint to known hosts
add_github_to_known_hosts() {
    mkdir -p ~/.ssh
    touch ~/.ssh/known_hosts
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts || {
        echo "Error: Failed to add GitHub to known hosts."
        exit 1
    }
    echo "GitHub's SSH key fingerprint added to known hosts."
}

# Function to prompt user to add SSH key to GitHub
prompt_to_add_key_to_github() {
    echo "Please add the SSH key to your GitHub account:"
    echo "1. Go to https://github.com/settings/keys"
    echo "2. Click on 'New SSH key'"
    echo "3. Paste the key and give it a title"
    echo "4. Confirm your GitHub username is \"$GITHUB_USERNAME\""
    read -p "Press Enter to continue after adding the key..."
}

# Function to test SSH connection to GitHub
test_ssh_connection() {
    ssh -T git@github.com || {
        echo "Error: SSH connection to GitHub failed."
        exit 1
    }
    echo "SSH connection to GitHub successful."
}

# Main script execution
main() {
    # Check for necessary dependencies
    check_dependencies

    # Elevate privileges at the start
    sudo -v || {
        echo "Error: Failed to elevate privileges."
        exit 1
    }

    # Add GitHub to known hosts
    add_github_to_known_hosts

    # Generate SSH key
    generate_ssh_key

    # Add SSH key to ssh-agent
    add_ssh_key_to_agent

    # Copy SSH key to clipboard
    copy_ssh_key_to_clipboard

    # Prompt user to add SSH key to GitHub
    prompt_to_add_key_to_github

    # Test SSH connection to GitHub
    test_ssh_connection

    echo "Script completed successfully."
}

# Run the main function
main
