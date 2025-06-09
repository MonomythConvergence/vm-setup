#!/bin/bash
set -e

echo "=== GUEST ADDITIONS INSTALLATION (FIXED) ==="

# Verify ISO mount
if ! sudo mount /dev/sr0 /mnt 2>/dev/null && ! sudo mount /dev/cdrom /mnt 2>/dev/null; then
  echo "ERROR: Insert Guest Additions CD via VirtualBox UI first:"
  echo "Devices > Optical Drives > Choose Disk Image"
  exit 1
fi

# Verify installer filename
INSTALLER=$(ls /mnt/VBoxLinuxAdditions.run 2>/dev/null || ls /mnt/VBox*.run | head -1)
if [ -z "$INSTALLER" ]; then
  echo "ERROR: No valid installer found in /mnt/"
  exit 1
fi

# Install dependencies
sudo apt update
sudo apt install -y build-essential dkms linux-headers-$(uname -r)

# Run installer with accepted license
echo "=== RUNNING INSTALLER ==="
sudo $INSTALLER --accept

# Post-install setup
sudo /sbin/rcvboxadd setup
sudo usermod -aG vboxsf $USER

# Verification
echo "=== VERIFICATION ==="
[ -f /usr/lib/virtualbox/vboxdrv.sh ] && echo "✓ Kernel modules exist" || echo "✗ Missing modules"
systemctl is-active vboxadd-service && echo "✓ Service running" || echo "✗ Service inactive"

# Cleanup
sudo umount /mnt
echo "=== INSTALLATION COMPLETE ==="
