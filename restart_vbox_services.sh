#!/bin/bash
set -e

echo "=== HEADLESS CLIPBOARD FIX ==="

# 1. Stop interfering services
sudo systemctl stop vboxadd-service 2>/dev/null || true
killall VBoxClient 2>/dev/null || true

# 2. Configure kernel-level clipboard
sudo mkdir -p /etc/vbox/
echo 'INSTALL_DIR=/usr/lib/virtualbox
VBOXCLIPBOARD_MODE=Kernel' | sudo tee /etc/vbox/vbox.cfg

# 3. Create headless startup service
sudo bash -c 'cat > /etc/systemd/system/vboxclipboard.service <<EOF
[Unit]
Description=VirtualBox Headless Clipboard
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/VBoxClient --clipboard=kernel
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF'

# 4. Reload and start services
sudo systemctl daemon-reload
sudo systemctl enable vboxclipboard
sudo systemctl start vboxclipboard

# 5. Verify installation
echo "=== VERIFICATION ==="
sleep 2
systemctl status vboxclipboard --no-pager
sudo dmesg | grep -i vboxclip
echo "=== SETUP COMPLETE ==="
