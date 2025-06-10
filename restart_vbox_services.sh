#!/bin/bash
set -e

echo "=== FINAL HEADLESS CLIPBOARD SOLUTION ==="

# 1. Ensure kernel modules are loaded
sudo modprobe vboxguest vboxsf

# 2. Create alternative clipboard interface
sudo mkdir -p /var/run/vboxguest
sudo touch /var/run/vboxguest/clipboard
sudo chmod 666 /var/run/vboxguest/clipboard

# 3. Create clipboard monitoring service
sudo bash -c 'cat > /etc/systemd/system/vboxclipboard-monitor.service <<EOF
[Unit]
Description=VirtualBox Clipboard Monitor
After=vboxadd-service.service

[Service]
Type=simple
ExecStart=/bin/bash -c "while true; do sudo cat /dev/vboxguest > /var/run/vboxguest/clipboard; sleep 1; done"
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# 4. Enable services
sudo systemctl daemon-reload
sudo systemctl enable vboxclipboard-monitor
sudo systemctl start vboxclipboard-monitor

# 5. Create user access scripts
sudo bash -c 'cat > /usr/local/bin/vbox-copy <<EOF
#!/bin/bash
cat \$1 > /var/run/vboxguest/clipboard
EOF'

sudo bash -c 'cat > /usr/local/bin/vbox-paste <<EOF
#!/bin/bash
cat /var/run/vboxguest/clipboard
EOF'

sudo chmod +x /usr/local/bin/vbox-{copy,paste}

echo "=== INSTALLATION COMPLETE ==="
echo "Usage:"
echo "  vbox-copy file.txt      # Copy to host"
echo "  vbox-paste              # Paste from host"
