#!/usr/bin/env bash
set -euo pipefail

FLAKE_ATTR="nixos"

# 1. Prepare Workspace
rm -rf nixos-config
git clone https://github.com/greyxp1/nixos-config.git
cd nixos-config

echo "--------------------------------------------------------------------------------"
echo "Detected the following physical disks:"
echo

# Use lsblk -d to show only full disks, excluding partitions and loop devices
i=0
declare -A DEVICES
while read -r dev; do
    echo "[$i] /dev/$dev"
    DEVICES[$i]="/dev/$dev"
    i=$((i+1))
done < <(lsblk -dn -o NAME,TYPE | grep disk | awk '{print $1}')

echo
# Force read from the terminal device (/dev/tty)
read -p "Which device do you wish to install on? " CHOICE < /dev/tty

DEV=${DEVICES[$CHOICE]}

if [ -z "$DEV" ]; then
    echo "Invalid selection. Exiting."
    exit 1
fi

echo "Selected: $DEV"
read -p "Confirm formatting $DEV? (y/n): " CONFIRM < /dev/tty
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# 3. Disk Setup
echo "Running Disko..."
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- --mode destroy,format,mount \
  --yes-wipe-all-disks \
  ./disko-config.nix \
  --argstr device "$DEV"

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
