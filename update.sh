#!/bin/bash

set -e

echo "=== Proxmox Host Update ==="

apt update
apt full-upgrade -y
apt autoremove -y
apt autoclean

echo
echo "=== Cleanup complete ==="
echo "Kernel:"
uname -r

echo
echo "Disk usage:"
df -h /

echo
echo "Done."
echo
echo "It is highly recommended to reboot your nodes afterwards"
echo