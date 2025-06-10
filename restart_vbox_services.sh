#!/bin/bash
echo "sudo chown -R \$USER:vboxsf /media/sf_*" | sudo tee /etc/rc.local
sudo chmod +x /etc/rc.local
sudo systemctl enable rc-local
