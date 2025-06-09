#!/bin/bash
set -e

# Verify CD inserted
if ! lsblk | grep -i cdrom; then
  echo "ERROR: Insert Guest Additions CD via VirtualBox UI first (Devices > Insert Guest Additions CD Image)"
  exit 1
fi

# Install dependencies
sudo apt update
sudo apt install -y build-essential dkms linux-headers-$(uname -r)

# Mount and install
sudo mkdir -p /mnt/cdrom
sudo mount /dev/cdrom /mnt/cdrom 2>/dev/null || sudo mount /dev/sr0 /mnt/cdrom
sudo /mnt/cdrom/VBoxLinuxAdditions.run
sudo usermod -aG vboxsf $USER

# Verify
echo "==== GUEST ADDITIONS VERIFICATION ===="
sudo /usr/sbin/VBoxService --version && echo "SUCCESS" || echo "FAILED"
echo "Rebooting in 5s..."
sleep 5
sudo reboot
