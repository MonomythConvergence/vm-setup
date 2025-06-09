#!/bin/bash
# CORRECTED VirtualBox Service Restart Script
echo "=== RESTARTING VIRTUALBOX SERVICES ==="

# Verify vboxdrv.sh exists
if [ ! -f /usr/lib/virtualbox/vboxdrv.sh ]; then
    echo "ERROR: VirtualBox kernel modules not found. Reinstall Guest Additions."
    echo "Run: sudo /mnt/cdrom/VBoxLinuxAdditions.run"
    exit 1
fi

# Rebuild modules
sudo /usr/lib/virtualbox/vboxdrv.sh setup || {
    echo "ERROR: Module rebuild failed. Check logs:"
    echo "cat /var/log/vboxadd-install.log"
    exit 1
}

# Restart services
sudo systemctl restart vboxadd-service vboxadd || {
    echo "WARNING: Service restart failed (continuing anyway)"
}

# Start vboxclient
VBoxClient --clipboard 2>/dev/null || {
    echo "WARNING: vboxclient failed to start"
}

echo "=== SERVICE RESTART COMPLETE ==="
