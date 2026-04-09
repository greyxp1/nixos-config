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

# Generate a simple list of disks
mapfile -t DISKS < <(lsblk -dpno NAME,SIZE,MODEL | grep disk)

if [ ${#DISKS[@]} -eq 0 ]; then
    echo "Error: No physical disks detected."
    exit 1
fi

# Display disks with index numbers
for i in "${!DISKS[@]}"; do
    echo "$((i+1))) ${DISKS[$i]}"
done

echo "------------------------------------------"
read -p "Select the disk number (1-${#DISKS[@]}): " CHOICE < /dev/tty

# Validate input
if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#DISKS[@]}" ]; then
    echo "Invalid selection: $CHOICE"
    exit 1
fi

# Extract the device path
DISK=$(echo "${DISKS[$((CHOICE-1))]}" | awk '{print $1}')

echo ""
echo "SELECTED: $DISK"
read -p "DANGER: This will WIPE ALL DATA on $DISK. Type 'y' to confirm: " CONFIRM < /dev/tty

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
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
