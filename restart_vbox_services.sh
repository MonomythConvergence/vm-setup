#!/bin/bash
set -e

echo "=== GUEST ADDITIONS FORCED INSTALLATION ==="

# 1. Verify ISO is inserted in VirtualBox UI
echo "1. Checking for mounted Guest Additions ISO..."

# 2. Force unmount and remount
sudo umount /mnt/cdrom 2>/dev/null || true
sudo mkdir -p /mnt/cdrom

if ! sudo mount /dev/sr0 /mnt/cdrom 2>/dev/null && ! sudo mount /dev/cdrom /mnt/cdrom 2>/dev/null; then
  echo "ERROR: No CDROM device detected. Confirm:"
  echo "1. ISO is inserted in VirtualBox UI (Devices > Optical Drives)"
  echo "2. VM has a virtual optical drive attached"
  exit 1
fi

# 3. Find installer (handle corrupted filenames)
INSTALLER=$(ls /mnt/cdrom/VBoxLinuxAdditions.run 2>/dev/null || ls /mnt/cdrom/VBox*.run | head -1)
if [ -z "$INSTALLER" ]; then
  echo "ERROR: No installer found in /mnt/cdrom/"
  echo "Contents of /mnt/cdrom/:"
  ls -l /mnt/cdrom/
  exit 1
fi

# 4. Install dependencies
echo "2. Installing dependencies..."
sudo apt update
sudo apt install -y build-essential dkms linux-headers-$(uname -r)

# 5. Run installer
echo "3. Running installer with --accept flag..."
sudo $INSTALLER --accept

# 6. Post-install setup
echo "4. Configuring kernel modules..."
sudo /sbin/rcvboxadd setup
sudo usermod -aG vboxsf $USER >/dev/null

# 7. Verification
echo "5. Verifying installation..."
[ -f /usr/lib/virtualbox/vboxdrv.sh ] && echo "✓ Kernel modules exist" || echo "✗ Missing kernel modules"
systemctl is-active vboxadd-service >/dev/null && echo "✓ Service running" || echo "✗ Service not running"

# 8. Cleanup
sudo umount /mnt/cdrom
echo "=== INSTALLATION COMPLETE ==="
