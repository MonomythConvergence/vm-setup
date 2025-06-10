#!/bin/bash
set -e

echo "=== GUEST ADDITIONS RECOVERY (READ-ONLY FIX) ==="

# 1. Create temporary mount point in user-writable location
MOUNT_DIR="$HOME/vbox_ga_mount"
mkdir -p "$MOUNT_DIR"

# 2. Force unmount if needed
sudo umount "$MOUNT_DIR" 2>/dev/null || true

# 3. Mount ISO from all possible device paths
if ! sudo mount /dev/sr0 "$MOUNT_DIR" 2>/dev/null && \
   ! sudo mount /dev/cdrom "$MOUNT_DIR" 2>/dev/null; then
  echo "ERROR: No CDROM device detected. Confirm:"
  echo "1. ISO is inserted in VirtualBox UI (Devices > Optical Drives)"
  echo "2. VM has a virtual optical drive attached"
  exit 1
fi

# 4. Find installer (handle corrupted filenames)
INSTALLER=$(ls "$MOUNT_DIR"/VBoxLinuxAdditions.run 2>/dev/null || \
            ls "$MOUNT_DIR"/VBox*.run | head -1)
if [ -z "$INSTALLER" ]; then
  echo "ERROR: No installer found in mounted ISO"
  echo "Contents of $MOUNT_DIR/:"
  ls -l "$MOUNT_DIR/"
  exit 1
fi

# 5. Install dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y build-essential dkms linux-headers-$(uname -r)

# 6. Run installer
echo "Running installer..."
sudo "$INSTALLER" --accept

# 7. Post-install setup
echo "Configuring kernel modules..."
sudo /sbin/rcvboxadd setup
sudo usermod -aG vboxsf $USER >/dev/null

# 8. Verification
echo "Verifying installation..."
[ -f /usr/lib/virtualbox/vboxdrv.sh ] && echo "✓ Kernel modules exist" || echo "✗ Missing modules"
systemctl is-active vboxadd-service >/dev/null && echo "✓ Service running" || echo "✗ Service inactive"

# 9. Cleanup
sudo umount "$MOUNT_DIR"
rmdir "$MOUNT_DIR"
echo "=== INSTALLATION COMPLETE ==="
