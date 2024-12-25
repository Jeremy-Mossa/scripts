#!/bin/bash

# Configuration
GITHUB_USERNAME="Jeremy-Mossa"
REPO1_NAME="Storage"
REPO2_NAME="scripts"
REPO1_URL="git@github.com:$GITHUB_USERNAME/$REPO1_NAME.git"
REPO2_URL="git@github.com:$GITHUB_USERNAME/$REPO2_NAME.git"
CLONE_DIR1="$HOME/$REPO1_NAME"
CLONE_DIR2="$HOME/scripts"
SCRIPT_PATH="$(realpath "$0")"
CRON_SCHEDULE="0 * * * * $SCRIPT_PATH"
USER_EMAIL=""
USER_NAME="Jeremy Mossa"

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
    elif command -v apk >/dev/null 2>&1; then
        sudo apk add "$1"
    else
        echo "Error: Package manager not found. Please install $1 manually."
        exit 1
    fi
}

# Function to check for necessary dependencies
check_dependencies() {
    local dependencies=("git" "cronie")
    for program in "${dependencies[@]}"; do
        check_program "$program"
    done
}

# Function to configure git user identity
configure_git_identity() {
    git config --global user.email "$USER_EMAIL"
    git config --global user.name "$USER_NAME"
}

# Function to clone the repository
clone_repository() {
    local repo_url="$1"
    local clone_dir="$2"
    if [ -d "$clone_dir" ]; then
        echo "Repository already cloned at $clone_dir."
    else
        git clone "$repo_url" "$clone_dir" || {
            echo "Error: Failed to clone the repository."
            exit 1
        }
        echo "Repository cloned to $clone_dir."
    fi
}

# Function to initialize git repository
initialize_git_repo() {
    local clone_dir="$1"
    local repo_name="$2"
    if [ ! -d "$clone_dir/.git" ]; then
        cd "$clone_dir" || {
            echo "Error: Failed to change directory to $clone_dir."
            exit 1
        }
        git init
        git remote add origin "git@github.com:$GITHUB_USERNAME/$repo_name.git" || {
            echo "Error: Failed to add remote repository."
            exit 1
        }
        echo "Initialized empty Git repository in $clone_dir"
    fi
}

# Function to get the default branch name
get_default_branch() {
    local repo_url="$1"
    git ls-remote --symref "$repo_url" HEAD | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}'
}

# Function to pull updates from GitHub
pull_updates() {
    local clone_dir="$1"
    local branch="$2"
    cd "$clone_dir" || {
        echo "Error: Failed to change directory to $clone_dir."
        exit 1
    }
    git pull origin "$branch" || {
        echo "Error: Failed to pull updates from GitHub."
        exit 1
    }
    echo "Updates pulled from GitHub in $clone_dir."
}

# Function to push changes to GitHub
push_changes() {
    local clone_dir="$1"
    local branch="$2"
    cd "$clone_dir" || {
        echo "Error: Failed to change directory to $clone_dir."
        exit 1
    }
    git add .
    git commit -m "Automated commit" || {
        echo "No changes to commit in $clone_dir."
        return 0
    }
    git push origin "$branch" || {
        echo "Error: Failed to push changes to GitHub from $clone_dir."
        exit 1
    }
    echo "Changes pushed to GitHub from $clone_dir."
}

# Function to sync the repository
sync_repository() {
    local repo_url="$1"
    local clone_dir="$2"
    local repo_name="$3"
    local branch
    branch=$(get_default_branch "$repo_url")
    if [ -z "$branch" ]; then
        echo "Error: Failed to determine default branch for $repo_url."
        exit 1
    fi
    clone_repository "$repo_url" "$clone_dir"
    initialize_git_repo "$clone_dir" "$repo_name"
    pull_updates "$clone_dir" "$branch"
    push_changes "$clone_dir" "$branch"
}

# Function to setup cron job
setup_cron_job() {
    if ! crontab -l | grep -F "$SCRIPT_PATH" >/dev/null 2>&1; then
        (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE") | crontab -
        echo "Cron job added to run the script every hour."
    else
        echo "Cron job already exists."
    fi
}

# Function to handle errors and cleanup
handle_error() {
    local exit_code="$?"
    if [ "$exit_code" -ne 0 ]; then
        echo "An error occurred during the execution of the script. Exit code: $exit_code"
    fi
    exit "$exit_code"
}

# Trap errors and cleanup
trap 'handle_error' EXIT

# Main script execution
main() {
    # Check for necessary dependencies
    check_dependencies

    # Configure git user identity
    configure_git_identity

    # Sync the first repository (Storage)
    sync_repository "$REPO1_URL" "$CLONE_DIR1" "$REPO1_NAME"

    # Sync the second repository (scripts)
    sync_repository "$REPO2_URL" "$CLONE_DIR2" "$REPO2_NAME"

    # Setup cron job to run this script every hour
    setup_cron_job

    echo "Script completed successfully."
}

# Run the main function
main
