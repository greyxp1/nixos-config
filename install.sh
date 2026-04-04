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
# This ensures your disko-config uses the physical drive you passed as an argument
sed -i "s|__TARGET_DISK__|$DISK|g" disko-config.nix

echo ">>> Running disko-install..."
# We use the direct executable path to ensure arguments are passed correctly
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode disko-install \
  --flake ".#default" \
  --write-efi-boot-entries \
  --yes-wipe-all-disks \
  main "$DISK"
