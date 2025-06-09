#!/bin/bash
sudo /usr/lib/virtualbox/vboxdrv.sh setup  # Rebuild modules
sudo systemctl restart vboxadd-service
