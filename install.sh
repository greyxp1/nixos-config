#!/usr/bin/env bash
set -euo pipefail

# 1. Prepare Workspace
echo "Cloning configuration..."
rm -rf nixos-config
git clone https://github.com/greyxp1/nixos-config.git
cd nixos-config

# 2. Interactive Disk Selection via JSON
echo "------------------------------------------"
echo "AVAILABLE DISKS:"
echo "------------------------------------------"

# Use JSON to avoid parsing issues with columns/tree lines
# We filter for 'disk' type and skip 'loop' devices
mapfile -t DEVICE_PATHS < <(lsblk -Jno NAME,SIZE,MODEL,TYPE | jq -r '.blockdevices[] | select(.type == "disk") | "/dev/" + .name')
mapfile -t DEVICE_INFO < <(lsblk -Jno NAME,SIZE,MODEL,TYPE | jq -r '.blockdevices[] | select(.type == "disk") | .name + " (" + .size + ") " + (.model // "")')

if [ ${#DEVICE_PATHS[@]} -eq 0 ]; then
    echo "Error: No disks found even with JSON parsing."
    echo "Current lsblk output for debugging:"
    lsblk
    exit 1
fi

# Display the menu
for i in "${!DEVICE_INFO[@]}"; do
    echo "$((i+1))) ${DEVICE_INFO[$i]}"
done

echo "------------------------------------------"
read -p "Select the disk number (1-${#DEVICE_PATHS[@]}): " CHOICE < /dev/tty

# Validate and Assign
if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -le "${#DEVICE_PATHS[@]}" ] && [ "$CHOICE" -gt 0 ]; then
    DISK="${DEVICE_PATHS[$((CHOICE-1))]}"
else
    echo "Invalid selection."
    exit 1
fi

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
