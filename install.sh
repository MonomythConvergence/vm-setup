#!/bin/bash
echo "==== CLIPBOARD DIAGNOSTICS ===="

# 1. Check VirtualBox services
echo -e "\n[1] Guest Additions Status:"
systemctl status vboxadd-service --no-pager | grep -E "Active:|Loaded:"
vboxclient --version 2>/dev/null || echo "vboxclient not found"

# 2. Verify kernel modules
echo -e "\n[2] Loaded Kernel Modules:"
lsmod | grep vbox

# 3. Check X11/Wayland environment
echo -e "\n[3] Display Environment:"
echo -n "DISPLAY: "; printenv DISPLAY
echo -n "XDG_SESSION_TYPE: "; echo $XDG_SESSION_TYPE
which xclip 2>/dev/null && echo "xclip installed" || echo "xclip missing"

# 4. Test clipboard mechanisms
echo -e "\n[4] Clipboard Tests:"
if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
  which wl-copy 2>/dev/null && echo "wl-copy available" || echo "Wayland: Install wl-clipboard"
else
  xhost >/dev/null 2>&1 && echo "X11 access granted" || echo "X11 access denied"
fi

# 5. Shared folder check
echo -e "\n[5] Shared Folders:"
mount | grep vboxsf || echo "No shared folders mounted"

# 6. Suggested fixes
echo -e "\n==== SUGGESTED ACTIONS ===="
if ! systemctl is-active vboxadd-service >/dev/null; then
  echo "1. Restart Guest Additions: sudo /sbin/rcvboxadd setup"
fi
if ! lsmod | grep -q vbox; then
  echo "2. Rebuild kernel modules: sudo /usr/lib/virtualbox/vboxdrv.sh setup"
fi
if [[ -z $DISPLAY ]]; then
  echo "3. Set DISPLAY: export DISPLAY=:0"
fi
if ! which xclip >/dev/null && [[ $XDG_SESSION_TYPE != "wayland" ]]; then
  echo "4. Install xclip: sudo apt install xclip"
fi
echo "============================="
