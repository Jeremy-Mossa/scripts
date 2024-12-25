#!/bin/bash

# Configuration
SCRIPT_PATH="$HOME/scripts/git-autopush.sh"
SERVICE_PATH="/etc/systemd/system/git-autopush.service"
TIMER_PATH="/etc/systemd/system/git-autopush.timer"

# Create the systemd service unit file
create_service_unit() {
    if [ ! -f "$SERVICE_PATH" ]; then
        sudo bash -c "cat <<EOF > $SERVICE_PATH
[Unit]
Description=Automatically push changes to all git repositories

[Service]
ExecStart=/bin/bash $SCRIPT_PATH
EOF"
        sudo chmod 644 "$SERVICE_PATH"
        echo "git-autopush.service created."
    else
        echo "git-autopush.service already exists."
    fi
}

# Create the systemd timer unit file
create_timer_unit() {
    if [ ! -f "$TIMER_PATH" ]; then
        sudo bash -c "cat <<EOF > $TIMER_PATH
[Unit]
Description=Run git-autopush.service every 15 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=15min

[Install]
WantedBy=timers.target
EOF"
        sudo chmod 644 "$TIMER_PATH"
        echo "git-autopush.timer created."
    else
        echo "git-autopush.timer already exists."
    fi
}

# Enable and start the systemd timer
enable_and_start_timer() {
    sudo systemctl daemon-reload
    sudo systemctl enable git-autopush.timer
    sudo systemctl start git-autopush.timer
    echo "git-autopush.timer enabled and started."
}

# Main script execution
main() {
    # Create the systemd service and timer
    create_service_unit
    create_timer_unit

    # Enable and start the timer
    enable_and_start_timer

    echo "Setup completed successfully."
}

# Run the main function
main
