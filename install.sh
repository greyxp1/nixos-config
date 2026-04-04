#!/usr/bin/env bash
set -e

REPO=$1
DISK=$2

if [ -z "$REPO" ] || [ -z "$DISK" ]; then
    echo "Usage: install.sh <github-user/repo> <target-disk>"
    echo "Example: install.sh greyxp1/nixos-config /dev/sda"
    exit 1
fi

echo ">>> Cloning repository..."
rm -rf /tmp/nixos-install
git clone "https://github.com/$REPO.git" /tmp/nixos-install
cd /tmp/nixos-install

echo ">>> Running official disko-install..."
# Notice the '#disko-install' at the end of the URL. That was the missing link.
# The '--disk main "$DISK"' flag magically overwrites the disk path in your nix config!

sudo nix --experimental-features "nix-command flakes" \
  run 'github:nix-community/disko/latest#disko-install' -- \
  --flake ".#default" \
  --disk main "$DISK" \
  --write-efi-boot-entries

echo ">>> Installation complete! You can now type 'reboot'."
