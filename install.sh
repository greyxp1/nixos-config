#!/usr/bin/env bash
set -e

REPO=$1
DISK=$2

echo ">>> Cloning repository..."
# We clone to /tmp so we can modify the disk name safely
git clone https://github.com/$REPO.git /tmp/nixos-install
cd /tmp/nixos-install

echo ">>> Setting target disk to $DISK..."
# Swap the placeholder with the actual physical disk
sed -i "s|__TARGET_DISK__|$DISK|g" disko-config.nix

echo ">>> Partitioning and formatting $DISK..."
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko-config.nix

echo ">>> Generating hardware config for this specific machine..."
sudo mkdir -p /mnt/etc/nixos
# This captures the drivers and UUIDs for the PC you are currently sitting at
sudo nixos-generate-config --root /mnt

echo ">>> Preparing the Flake Bridge..."
# Copy the hardware file locally so the Flake can see it relatively
cp /mnt/etc/nixos/hardware-configuration.nix .
git add .

echo ">>> Installing NixOS..."
# We install from the local folder we just modified, using the impure flag
sudo nixos-install --no-root-passwd --flake .#default

echo ">>> Cleaning up and moving repo to your new home folder..."
sudo cp -r /tmp/nixos-install /mnt/home/nixos-config
# Give ownership to your new user (assuming UID 1000)
sudo chown -R 1000:100 /mnt/home/nixos-config

echo ">>> Done! You can now type 'reboot'."
