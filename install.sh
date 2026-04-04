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
sed -i "s|__TARGET_DISK__|$DISK|g" disko-config.nix

echo ">>> Running disko-install..."
# We use the full flake path and explicit flag for the disk
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode disko-install \
  --flake ".#default" \
  --yes-wipe-all-disks \
  --argstr device "$DISK"
