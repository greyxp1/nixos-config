#!/usr/bin/env bash
set -euo pipefail

# 1. Prepare Workspace
echo "Cloning configuration..."
rm -rf nixos-config
git clone https://github.com/greyxp1/nixos-config.git
cd nixos-config

# 2. Interactive Disk Selection
echo "------------------------------------------"
echo "AVAILABLE DISKS:"
echo "------------------------------------------"

# List disks with index numbers
mapfile -t DISK_LIST < <(lsblk -dn -o NAME,SIZE,MODEL | grep disk)

if [ ${#DISK_LIST[@]} -eq 0 ]; then
    echo "No disks found! Exiting."
    exit 1
fi

for i in "${!DISK_LIST[@]}"; do
    echo "$((i+1))) /dev/${DISK_LIST[$i]}"
done

echo "------------------------------------------"
# Force read from /dev/tty so curl | bash doesn't skip this
read -p "Select the disk number (1-${#DISK_LIST[@]}): " CHOICE < /dev/tty

# Extract the device name from the chosen line
DISK_NAME=$(echo "${DISK_LIST[$((CHOICE-1))]}" | awk '{print $1}')
DISK="/dev/$DISK_NAME"

if [ -z "$DISK_NAME" ]; then
    echo "Invalid selection. Exiting."
    exit 1
fi

echo ""
echo "SELECTED: $DISK"
read -p "DANGER: This will WIP ALL DATA on $DISK. Type 'y' to confirm: " CONFIRM < /dev/tty

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
echo "Setting up 4GB swapfile..."
sudo fallocate -l 4G /mnt/swapfile
sudo chmod 600 /mnt/swapfile
sudo mkswap /mnt/swapfile
sudo swapon /mnt/swapfile

# 5. Final Installation
echo "Starting NixOS Installation..."
sudo nixos-install --root /mnt --flake ".#$FLAKE_ATTR" --no-root-passwd

echo "Installation Complete. Rebooting in 5 seconds..."
sleep 5
sudo reboot
