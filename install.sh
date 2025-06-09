#!/bin/bash
# Check if ISO is detected by the VM
lsblk | grep -i cdrom  # Should show /dev/sr0 or similar
sudo blkid /dev/sr0    # Verify filesystem type (iso9660)
