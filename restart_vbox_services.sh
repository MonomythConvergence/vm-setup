#!/bin/bash
sudo chown -R $USER:vboxsf /media/sf_* && sudo chmod -R 775 /media/sf_* && \
echo "✓ Full write access granted to $(whoami)"
