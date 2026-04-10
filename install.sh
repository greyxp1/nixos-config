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

# 2. Extract disks and exclude the loop device and the installer USB (/iso)
mapfile -t DISK_NAMES < <(lsblk -dn -o NAME,TYPE,MOUNTPOINTS | grep disk | grep -v '/iso' | awk '{print $1}')
mapfile -t DISK_INFO < <(lsblk -dn -o NAME,SIZE,MODEL | grep -v 'loop' | grep -v 'sda') # Simple filter for display

i=0
for name in "${DISK_NAMES[@]}"; do
    # Get size for a better display
    SIZE=$(lsblk -dno SIZE "/dev/$name")
    echo "[$i] /dev/$name ($SIZE)"
    i=$((i+1))
done

echo
# Force use of /dev/tty for input
exec < /dev/tty
read -p "Which device do you wish to install on? (Enter number): " CHOICE

DEV="/dev/${DISK_NAMES[$CHOICE]}"

echo "Selected: $DEV"
read -p "DANGER: This will WIPE $DEV. Are you sure? (y/n): " CONFIRM

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

echo "Updating flake with selected device: $DEV"
# This replaces the hardcoded device in specialArgs within flake.nix
sed -i "s|device = \".*\"; # Default|device = \"$DEV\"; # Default|" flake.nix

# 5. Final Installation
echo "Starting Installation..."
sudo nixos-install --root /mnt --flake ".#$FLAKE_ATTR" --no-root-passwd

echo "Installation Complete. Rebooting..."
#sudo reboot
