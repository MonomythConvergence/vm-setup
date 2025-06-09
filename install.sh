#!/bin/bash
apt update
apt install -y build-essential dkms linux-headers-$(uname -r)
mount /dev/cdrom /mnt
/mnt/VBoxLinuxAdditions.run
usermod -aG vboxsf $USER
mkdir -p /mnt/backend
echo "backend /mnt/backend vboxsf defaults,uid=$(id -u),gid=$(id -g) 0 0" >> /etc/fstab
mount -a
