#!/bin/sh

DIRS="
books
C
C++
Documents
perl
pics
wallpapers
videos
"

mkdir -p ~/.config
echo "enabled=False" > ~/.config/user-dirs.conf

# Remove default directories
rm -rf ~/Desktop ~/Videos ~/Music \
  ~/Templates ~/Pictures ~/Public \
  >/dev/null 2>/dev/null

# Create directories if they don't exist
for dir in $DIRS; do
  if [ ! -d ~/$dir ]; then
    mkdir ~/$dir
  fi
done

# Clone git repositories if they don't exist
if [ ! -d ~/scripts ]; then
  git clone https://github.com/Jeremy-Mossa/scripts ~/scripts
fi
if [ ! -d ~/dotfiles ]; then
  git clone https://github.com/Jeremy-Mossa/dotfiles ~/dotfiles
fi
if [ ! -d ~/flutter ]; then
  git clone https://github.com/flutter/flutter.git -b stable ~/flutter
fi

# Create symbolic link if it doesn't exist
if [ ! -e ~/downloads ]; then
  ln -s ~/Downloads ~/downloads
fi


# Download Storage repository if it doesn't exist
if [ ! -d ~/Storage ]; then
  wget -O storage.zip \
  https://github.com/Jeremy-Mossa/Storage/archive/main.zip
  unzip storage.zip
  rm storage.zip
  mv Storage-main ~/Storage
fi

if [ ! -d ~/Downloads/scrcpy ]; then
  git clone https://github.com/Genymobile/scrcpy.git ~/Downloads/scrcpy
fi

cp ~/dotfiles/.fluxbox/autostart ~/.fluxbox/
cp ~/dotfiles/.kshrc ~/.kshrc
cp ~/dotfiles/.xinitrc ~/.xinitrc
cp ~/dotfiles/.Xresources ~/.Xresources
cp ~/dotfiles/.vimrc ~/.vimrc
cp ~/Storage/wallpapers/* ~/wallpapers/


###############################################################
# Fluxbox dock -- different time format
INIT_FILE="$HOME/.fluxbox/init"
CLOCK_FORMAT="session.screen0.strftimeFormat: %A -- %e %B %Y -- %H:%M"
if [ -f "$INIT_FILE" ]; then
    if ! grep -q "session.screen0.strftimeFormat" "$INIT_FILE"; then
        echo "$CLOCK_FORMAT" >> "$INIT_FILE"
    else
        sed -i "s/session.screen0.strftimeFormat.*/$CLOCK_FORMAT/" \
            "$INIT_FILE"
    fi
else
    mkdir -p "$HOME/.fluxbox"
    echo "$CLOCK_FORMAT" > "$INIT_FILE"
fi
###############################################################

################################################################
# Append to fluxbox keys file
# Define the path to the keys file
KEYS_FILE="$HOME/.fluxbox/keys"

# Create ~/.fluxbox directory and keys file if they don't exist
if [ ! -f "$KEYS_FILE" ]; then
    mkdir -p "$HOME/.fluxbox"
    touch "$KEYS_FILE"
fi

# Define the lines to check/append as a newline-separated string
KEYS="# GUI in current workspace
Control Mod1 t :ExecCommand xterm -geometry 65x15
Control Mod1 h :ExecCommand xterm -geometry 65x53
Control Mod1 b :ExecCommand /usr/bin/perl ~/scripts/grok2.pl
Control Mod1 d :ExecCommand dillo
Control Mod1 i :ExecCommand icecat
Control Mod1 l :ExecCommand libreoffice
Control Mod1 v :ExecCommand vimb
Control Mod1 f :Maximize"

# Function to check and append a single line if it doesn't exist
check_and_append_line() {
    line="$1"
    # Escape special characters for grep
    escaped_line=$(echo "$line" | sed 's/[\[\.*^$/]/\\&/g')
    if ! grep -Fx "$escaped_line" "$KEYS_FILE" >/dev/null; then
        echo "$line" >> "$KEYS_FILE"
    fi
}

# Process each line
echo "$KEYS" | while IFS= read -r line; do
    check_and_append_line "$line"
done
################################################################

# Increase workspaces in Fluxbox from 4 to 6
if ! grep -Fx "session.screen0.workspaces: 6" "$HOME/.fluxbox/init" >/dev/null; then
    echo "session.screen0.workspaces: 6" >> "$HOME/.fluxbox/init"
fi

# Configure display manager
if command -v slim > /dev/null && ! systemctl status gdm | grep -q "disabled"; then
  systemctl disable gdm 2>/dev/null
  systemctl enable slim 2>/dev/null
else
  gdmstatus=$(systemctl status gdm | grep "disabled")
  echo "gdm status: $gdmstatus"
fi

if ! getent passwd jbm | grep -q ":jbm:.*:/bin/ksh$"; then
  chsh -s "/bin/ksh" "jbm"
fi

###############################################################
# Exit on any error
set -e 

# Define variables
SSH_DIR="$HOME/.ssh"
KEY_TYPE="ed25519"
KEY_FILE="$SSH_DIR/id_$KEY_TYPE"
COMMENT="$(whoami)@$(hostname)"
GROK_USERNAME_FILE="$SSH_DIR/grok_username"
GROK_PASSWORD_FILE="$SSH_DIR/grok_password"
LINE_USERNAME_FILE="$SSH_DIR/line_username"
LINE_PASSWORD_FILE="$SSH_DIR/line_password"

# Create ~/.ssh directory if it doesn't exist
if [ ! -d "$SSH_DIR" ]; then
    mkdir "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# Prompt for Grok username and save it if DNE
if [ ! -f "$GROK_USERNAME_FILE" ]; then
    echo "Enter your Grok username:"
    read grok_username
    echo "$grok_username" > "$GROK_USERNAME_FILE"
    chmod 600 "$GROK_USERNAME_FILE"
fi

# Prompt for Grok password and save it if DNE
if [ ! -f "$GROK_PASSWORD_FILE" ]; then
    echo "Enter your Grok password:"
    read grok_password
    echo "$grok_password" > "$GROK_PASSWORD_FILE"
    chmod 600 "$GROK_PASSWORD_FILE"
fi

# Prompt for Line username and save it if DNE
if [ ! -f "$LINE_USERNAME_FILE" ]; then
    echo "Enter your Line username:"
    read line_username
    echo "$line_username" > "$LINE_USERNAME_FILE"
    chmod 600 "$LINE_USERNAME_FILE"
fi

# Prompt for Line password and save it if DNE
if [ ! -f "$LINE_PASSWORD_FILE" ]; then
    echo "Enter your Line password:"
    read line_password
    echo "$line_password" > "$LINE_PASSWORD_FILE"
    chmod 600 "$LINE_PASSWORD_FILE"
fi

# Generate SSH key pair if it doesn't exist
if [ ! -f "$KEY_FILE" ]; then
    ssh-keygen -t "$KEY_TYPE" -f "$KEY_FILE" -C "$COMMENT" -N ""
fi

# Set correct permissions
chmod 600 "$KEY_FILE"
chmod 644 "$KEY_FILE.pub"

# Optionally, create a basic ~/.ssh/config file
CONFIG_FILE="$SSH_DIR/config"
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" <<EOF
# SSH client configuration
Host *
    StrictHostKeyChecking ask
    IdentityFile $KEY_FILE
EOF
    chmod 600 "$CONFIG_FILE"
fi

# Verify setup
echo "SSH setup complete for $(whoami)."
echo "Private key: $KEY_FILE"
echo "Public key: $KEY_FILE.pub"
echo "Grok username saved to: $GROK_USERNAME_FILE"
echo "Grok password saved to: $GROK_PASSWORD_FILE"
echo "Public key contents:"
cat "$KEY_FILE.pub"
###############################################################

# ==============================================================================
# Below is from Grok 4.1
# ==============================================================================

echo "Configuring SSH remotes (ssh://git@github.com/…) for your repositories..."

# 1. ~/scripts
if [ -d ~/scripts/.git ]; then
    git -C ~/scripts remote set-url origin ssh://git@github.com/Jeremy-Mossa/scripts.git
    echo "→ ~/scripts   → SSH remote set"
fi

# 2. ~/dotfiles
if [ -d ~/dotfiles/.git ]; then
    git -C ~/dotfiles remote set-url origin ssh://git@github.com/Jeremy-Mossa/dotfiles.git
    echo "→ ~/dotfiles  → SSH remote set"
fi

# 3. ~/Storage – was downloaded as zip → no git history → replace with real SSH clone
if [ -d ~/Storage ] || [ -d ~/Storage ]; then
    echo "Replacing ~/Storage zip extract with proper SSH-cloned repository..."
    rm -rf ~/Storage
    git clone ssh://git@github.com/Jeremy-Mossa/Storage.git ~/Storage
    echo "→ ~/Storage   → cloned over SSH (now fully functional)"
fi

# Optional pretty output so you can see it worked
echo ""
echo "Final remote configuration:"
echo "─────────────────────────────"
git -C ~/scripts  remote get-url origin 2>/dev/null || echo "scripts:   not found"
git -C ~/dotfiles remote get-url origin 2>/dev/null || echo "dotfiles:  not found"
git -C ~/Storage  remote get-url origin 2>/dev/null || echo "Storage:   not found"
echo ""
