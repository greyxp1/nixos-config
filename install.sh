#!/usr/bin/env bash
set -e

REPO=$1
DISK=$2

if [ -z "$REPO" ] || [ -z "$DISK" ]; then
    echo "Usage: install.sh <user/repo> <disk>"
    exit 1
fi

echo ">>> Cloning repository..."
rm -rf /tmp/nixos-install
git clone "https://github.com/$REPO.git" /tmp/nixos-install
cd /tmp/nixos-install

echo ">>> Setting target disk to $DISK in disko-config.nix..."
# This swaps your placeholder for the real disk path
sed -i "s|__TARGET_DISK__|$DISK|g" disko-config.nix

echo ">>> Running disko-install..."
# Syntax breakdown:
# --mode disko-install : The action
# --flake .#default     : The configuration to use
# --yes-wipe-all-disks : Automation safety bypass
# main "$DISK"         : Map the 'main' definition in Nix to the physical disk
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode disko-install \
  --flake ".#default" \
  --yes-wipe-all-disks \
  --write-efi-boot-entries \
  main "$DISK"
