#!/bin/bash
echo "==== PRE-SETUP DIAGNOSTICS ===="
echo -n "Kernel: "; uname -r
echo -n "Mounted CDs: "; lsblk | grep -i cdrom
echo -n "Build Tools: "; dpkg -l build-essential dkms linux-headers-generic | grep ^ii
echo -n "Docker Status: "; snap list docker 2>/dev/null || echo "Not installed"
echo -n "vboxsf Group: "; groups | grep vboxsf || echo "User not in vboxsf"
echo "==============================="
