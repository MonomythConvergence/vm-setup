#!/bin/bash
set -e

# 1. Verify ISO is detected
echo "==== VERIFYING CDROM ===="
CD_DEVICE="/dev/sr0"
if ! sudo blkid "$CD_DEVICE" | grep -q "TYPE=\"iso9660\""; then
  echo "ERROR: Insert Guest Additions ISO via VirtualBox UI (Devices > Insert Guest Additions CD Image)"
  exit 1
fi

# 2. Install dependencies
echo "==== INSTALLING DEPENDENCIES ===="
sudo apt update
sudo apt install -y build-essential dkms linux-headers-$(uname -r)

# 3. Force unmount and remount
echo "==== MOUNTING ISO ===="
sudo umount /mnt/cdrom 2>/dev/null || true
sudo mkdir -p /mnt/cdrom
sudo mount -t iso9660 "$CD_DEVICE" /mnt/cdrom

# 4. Install Guest Additions
echo "==== INSTALLING GUEST ADDITIONS ===="
sudo /mnt/cdrom/VBoxLinuxAdditions.run || echo "Continue despite installer exit code..."

# 5. Verify installation
echo "==== VERIFYING INSTALLATION ===="
sudo /usr/lib/virtualbox/vboxdrv.sh status || echo "Kernel modules not loaded (reboot may fix)"

# 6. Add user to vboxsf group
sudo usermod -aG vboxsf $USER
echo "User added to vboxsf group. Reboot to apply changes."

# 7. Optional: Check clipboard service
systemctl is-active vboxadd-service >/dev/null && echo "Clipboard service active" || echo "Clipboard service inactive (may need reboot)"
