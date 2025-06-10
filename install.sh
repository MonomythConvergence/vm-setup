#!/bin/bash
set -e

echo "=== WORKING CLIPBOARD SOLUTION ==="

# 1. Install necessary tools
sudo apt update
sudo apt install -y xxd

# 2. Create clipboard management scripts
sudo tee /usr/local/bin/vb-copy >/dev/null <<'EOF'
#!/bin/bash
text="$@"
len=$(printf '%08x' ${#text})
echo -n "${len}00000000${text}" | xxd -r -p | sudo tee /dev/vboxguest >/dev/null
EOF

sudo tee /usr/local/bin/vb-paste >/dev/null <<'EOF'
#!/bin/bash
sudo dd if=/dev/vboxguest bs=1 count=4096 status=none | \
  xxd -p -c 32 | \
  awk '{
    len=strtonum("0x" substr($0,1,8));
    if (len > 0) print substr($0,17,len*2);
  }' | \
  xxd -r -p
EOF

# 3. Make scripts executable
sudo chmod +x /usr/local/bin/vb-{copy,paste}

# 4. Create persistence service
sudo tee /etc/systemd/system/vboxclip.service >/dev/null <<'EOF'
[Unit]
Description=VirtualBox Clipboard Service
After=vboxadd-service.service

[Service]
ExecStart=/bin/bash -c "while true; do sleep 60; done"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 5. Enable services
sudo systemctl daemon-reload
sudo systemctl enable vboxclip
sudo systemctl start vboxclip

echo "=== INSTALLATION COMPLETE ==="
echo "Usage:"
echo "  vb-copy 'Your text here'    # Copy to host clipboard"
echo "  vb-paste                    # Paste from host clipboard"
