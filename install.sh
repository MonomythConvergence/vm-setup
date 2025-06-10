#!/bin/bash
# 1. Ensure your user is in vboxsf group
sudo usermod -aG vboxsf $USER

# 2. Set default permissions for ALL shared folders
echo "options vboxsf uid=$(id -u),gid=$(id -g),dmode=775,fmode=664" | \
sudo tee -a /etc/modprobe.d/vboxsf.conf
