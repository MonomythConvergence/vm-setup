#!/bin/bash
set -e

echo "=== HEADLESS CLIPBOARD FINAL FIX ==="

# 1. Verify VirtualBox kernel modules
if ! lsmod | grep -q vboxguest; then
    echo "ERROR: vboxguest kernel module not loaded"
    echo "Rebuild modules with: sudo /sbin/rcvboxadd setup"
    exit 1
fi

# 2. Configure kernel clipboard
sudo mkdir -p /etc/vbox
echo 'INSTALL_DIR=/usr/lib/virtualbox
VBOXCLIPBOARD_MODE=kernel' | sudo tee /etc/vbox/vbox.cfg

# 3. Create direct access service
sudo bash -c 'cat > /etc/systemd/system/vboxclipboard.service <<EOF
[Unit]
Description=VirtualBox Headless Clipboard
After=vboxadd-service.service
Requires=vboxadd-service.service

[Service]
Type=simple
ExecStart=/usr/bin/VBoxClient --clipboard
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF'

# 4. Reload services
sudo systemctl daemon-reload
sudo systemctl enable vboxclipboard
sudo systemctl restart vboxadd-service
sudo systemctl restart vboxclipboard

# 5. Verify
echo "=== VERIFICATION ==="
sleep 2
systemctl status vboxclipboard --no-pager
[ -e /dev/vboxguest ] && echo "✓ vboxguest device present" || echo "✗ Missing vboxguest device"
sudo ls -l /proc/vboxguest/ || echo "✗ No vboxguest proc interface"

echo "=== SETUP COMPLETE ==="
