#!/bin/bash
set -e

# Check for CDROM device (retry 3 times)
for i in {1..3}; do
  CD_DEVICE=$(lsblk -o NAME,MOUNTPOINT | grep -i 'cdrom.*/mnt' | awk '{print $1}' || true)
  [ -n "$CD_DEVICE" ] && break
  echo "Retrying CD detection ($i/3)..."
  sleep 2
done

# Fallback to direct device check
if [ -z "$CD_DEVICE" ]; then
  CD_DEVICE=$(ls /dev/sr* 2>/dev/null | head -1)
  [ -z "$CD_DEVICE" ] && echo "ERROR: No CDROM device found. Confirm ISO is inserted in VirtualBox UI." && exit 1
fi

# Install dependencies
sudo apt update
sudo apt install -y build-essential dkms linux-headers-$(uname -r)

# Mount ISO
sudo mkdir -p /mnt/cdrom
sudo umount /mnt/cdrom 2>/dev/null || true
sudo mount $CD_DEVICE /mnt/cdrom

# Install Guest Additions
sudo /mnt/cdrom/VBoxLinuxAdditions.run
sudo usermod -aG vboxsf $USER

# Verify
echo "==== VERIFICATION ===="
sudo /usr/lib/virtualbox/vboxdrv.sh status
echo "Rebooting..."
sudo reboot
