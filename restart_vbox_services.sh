#!/bin/bash
sudo usermod -aG vboxsf $USER && newgrp vboxsf && \
ls /media/sf_*/ && echo "✓ Shared folders mounted"
