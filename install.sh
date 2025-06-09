#!/bin/bash
# Fixes X11 permissions and display issues
echo "=== FIXING X11 ACCESS ==="

# Install required packages
sudo apt update && sudo apt install -y xauth x11-xserver-utils virtualbox-guest-utils 2>/dev/null || {
    echo "ERROR: Package installation failed"
    exit 1
}

# Configure X11 permissions
xhost +local: 2>/dev/null || {
    echo "WARNING: xhost command failed (may need manual intervention)"
}

# Set display variable
if [[ -z "$DISPLAY" ]]; then
    echo "export DISPLAY=:0" >> ~/.bashrc
    source ~/.bashrc
    echo "Set DISPLAY=:0"
fi

echo "X11 configuration complete"
