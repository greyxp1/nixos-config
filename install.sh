#!/usr/bin/env bash
set -euo pipefail

# 1. Prepare Workspace
echo "Cloning configuration..."
rm -rf nixos-config
git clone https://github.com/greyxp1/nixos-config.git
cd nixos-config

# 2. Interactive Disk Selection (The Simple Way)
echo "------------------------------------------"
echo "AVAILABLE DISKS:"
echo "------------------------------------------"

# Get a raw list of disks: name, size, model
# We use a temp file to ensure the list persists across the pipe
lsblk -dn -o NAME,SIZE,MODEL | grep disk > /tmp/disks.txt

i=1
while read -r line; do
    echo "$i) /dev/$line"
    i=$((i+1))
done < /tmp/disks.txt

COUNT=$((i-1))

if [ "$COUNT" -eq 0 ]; then
    echo "No disks found. Check your hardware connections."
    exit 1
fi

echo "------------------------------------------"
echo -n "Select disk number (1-$COUNT): "
read -r CHOICE < /dev/tty

# Get the specific device name from the temp file based on line number
DISK_NAME=$(sed -n "${CHOICE}p" /tmp/disks.txt | awk '{print $1}')
DISK="/dev/$DISK_NAME"

if [ -z "$DISK_NAME" ]; then
    echo "Invalid selection."
    exit 1
fi

echo ""
echo "SELECTED: $DISK"
echo -n "DANGER: Wipe all data on $DISK? (y/n): "
read -r CONFIRM < /dev/tty

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

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
sudo nixos-install --root /mnt --flake ".#nixos" --no-root-passwd

echo "Complete. Rebooting...."
sudo reboot
