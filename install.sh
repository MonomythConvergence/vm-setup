#!/bin/bash
set -e

echo "=== STARTING COMPREHENSIVE FIX ==="

# 1. Get user info
USER_ID=$(id -u)
GROUP_ID=$(id -g)
USERNAME=$(whoami)

# 2. Fix shared folder permissions
echo "1. Fixing shared folder permissions..."
sudo mkdir -p /media/sf_backend
sudo umount /media/sf_backend 2>/dev/null || true
sudo mount -t vboxsf -o rw,uid=$USER_ID,gid=$GROUP_ID,dmode=777,fmode=777 backend /media/sf_backend

# 3. Create permanent mount service
echo "2. Creating permanent mount service..."
sudo bash -c "cat > /etc/systemd/system/sf-backend-mount.service <<EOF
[Unit]
Description=Mount Shared Folder with User Permissions
After=vboxadd-service.service

[Service]
Type=oneshot
ExecStart=/bin/mount -t vboxsf -o rw,uid=$USER_ID,gid=$GROUP_ID,dmode=777,fmode=777 backend /media/sf_backend

[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload
sudo systemctl enable sf-backend-mount
sudo systemctl start sf-backend-mount

# 4. Verify mount
echo "3. Verifying mount..."
mount | grep sf_backend | grep "uid=$USER_ID" && echo "✓ Mount correct" || echo "✗ Mount failed"

# 5. Test write access
echo "4. Testing write access..."
touch /media/sf_backend/test_file && rm /media/sf_backend/test_file && echo "✓ Write access confirmed"

# 6. Start Docker Backend
echo "5. Starting Docker Backend..."
docker run -d -p 8000:8000 --name backend \
nikolaik/python-nodejs \
sh -c "pip install flask && echo 'from flask import Flask; app=Flask(__name__)
@app.route(\"/\")
def hello(): return \"Backend Accessible via HOST localhost\"' > app.py && python app.py"

# 7. Verify Docker
echo "6. Verifying Docker..."
docker ps --filter "name=backend" --format "table {{.Names}}\t{{.Status}}" | grep "Up" && echo "✓ Backend running" || echo "✗ Backend not running"

# 8. Port forwarding instructions
echo -e "\n=== MANUAL HOST ACTION REQUIRED ==="
echo "1. Shut down this VM"
echo "2. In VirtualBox:"
echo "   - Select VM → Settings → Network"
echo "   - Advanced → Port Forwarding"
echo "   - Add new rule:"
echo "        Name:    backend"
echo "        Protocol: TCP"
echo "        Host Port: 8000"
echo "        Guest Port: 8000"
echo "3. Restart VM"
echo -e "\n=== ACCESS INSTRUCTIONS ==="
echo "After restart and port forwarding setup:"
echo "1. Start Backend: docker start backend"
echo "2. Access from Windows host:"
echo "   - Browser: http://localhost:8000"
echo "   - PowerShell: curl http://localhost:8000"

echo -e "\n=== SCRIPT COMPLETE ==="
