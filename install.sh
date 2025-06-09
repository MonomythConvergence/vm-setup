#!/bin/bash
# Restarts all VirtualBox services properly
echo "=== RESTARTING VIRTUALBOX SERVICES ==="

# Rebuild kernel modules
sudo /usr/lib/virtualbox/vboxdrv.sh setup || {
    echo "ERROR: Failed to rebuild kernel modules"
    exit 1
}

# Restart services
sudo systemctl restart vboxadd-service vboxadd 2>/dev/null || {
    echo "WARNING: Some services failed to restart"
}

# Start vboxclient
/usr/bin/VBoxClient --clipboard 2>/dev/null && {
    echo "vboxclient started successfully"
} || {
    echo "ERROR: Failed to start vboxclient"
}

echo "Service restart complete"
