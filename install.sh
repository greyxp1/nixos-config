#!/usr/bin/env bash
set -euo pipefail

# 1. Prepare Workspace
rm -rf nixos-config
git clone https://github.com/greyxp1/nixos-config.git
cd nixos-config

# 2. Interactive Disk Selection
echo "Available Disks:"
# Displays NAME, SIZE, and MODEL to help you identify the right drive
lsblk -dn -o NAME,SIZE,MODEL | grep disk | awk '{print NR ") /dev/" $1 " - " $2 " " $3 $4}'

echo ""
read -p "Select the disk number to install NixOS on: " CHOICE

# Get the device name based on the user's choice
DISK=$(lsblk -dn -o NAME,TYPE | grep disk | sed -n "${CHOICE}p" | awk '{print "/dev/" $1}')

if [ -z "$DISK" ]; then
    echo "Invalid selection. Exiting."
    exit 1
fi

echo "Selected disk: $DISK"
read -p "WARNING: This will ERASE ALL DATA on $DISK. Continue? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

FLAKE_ATTR="nixos"

# 3. Disk Setup
echo "Running Disko..."
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- --mode destroy,format,mount \
  --yes-wipe-all-disks \
  ./disko-config.nix \
  --argstr device "$DISK"

# 4. Swap Setup
echo "Setting up swap..."
sudo fallocate -l 4G /mnt/swapfile
sudo chmod 600 /mnt/swapfile
sudo mkswap /mnt/swapfile
sudo swapon /mnt/swapfile

# 5. Final Installation
echo "Starting Installation..."
sudo nixos-install --root /mnt --flake ".#$FLAKE_ATTR" --no-root-passwd

echo "Installation Complete. Rebooting..."
sudo reboot
