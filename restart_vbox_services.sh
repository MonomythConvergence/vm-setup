#!/bin/bash
sudo mount -t vboxsf -o rw,uid=$(id -u),gid=$(id -g),dmode=775,fmode=664 backend /media/sf_backend
