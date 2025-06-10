#!/bin/bash
find /media -maxdepth 1 -name "sf_*" -exec sudo chown -R $USER:vboxsf {} \; -exec sudo chmod -R 775 {} \; && \
echo "✓ Full write access granted to $(whoami) for all shared folders"
