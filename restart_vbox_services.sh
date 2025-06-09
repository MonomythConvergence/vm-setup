#!/bin/bash
# SAFE Guest Additions Reinstall Script
set -e

echo "=== GUEST ADDITIONS RECOVERY ==="

# 1. Verify ISO Mount
if ! sudo mount /dev/sr0 /mnt 2>/dev/null && ! sudo mount /dev/cdrom /mnt 2>/dev/null; then
  echo "ERROR: Insert Guest Additions CD via VirtualBox UI first:"
  echo "Devices > Optical Drives > Choose Disk Image"
  exit 1
fi

# 2. Purge Old Installations
sudo apt purge -y virtualbox-guest-* 2>/dev/null || true

# 3. Install Dependencies
sudo apt update
sudo apt install -y build-essential dkms linux-headers-$(uname -r)

# 4. Run Installer
sudo /mnt/VBoxLinuxAdditions.run --force

# 5. Post-Install Setup
sudo /sbin/rcvboxadd setup
sudo usermod -aG vboxsf $USER

# 6. Verify
echo "=== VERIFICATION ==="
ls /usr/lib/virtualbox/vboxdrv.sh && echo "✓ Kernel modules exist" || echo "✗ Missing modules"
systemctl is-active vboxadd-service && echo "✓ Service running" || echo "✗ Service inactive"

# 7. Cleanup
sudo umount /mnt
echo "=== COMPLETE ==="
