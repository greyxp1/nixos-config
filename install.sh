#!/usr/bin/env bash
set -euo pipefail

DISK="/dev/nvme0n1"
FLAKE_ATTR="nixos"

# 1. Prepare Workspace
# Remove old folder if it exists to avoid 'already exists' errors
rm -rf nixos-config
git clone https://github.com/greyxp1/nixos-config.git
cd nixos-config

# 2. Network/DNS Fix (Prevents the 'Timeout reached' errors)
echo "Setting DNS to 8.8.8.8..."
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# 3. Disk Setup
echo "Running Disko..."
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- --mode destroy,format,mount \
  --yes-wipe-all-disks \
  ./disko-config.nix \
  --argstr device "$DISK"

# 4. Memory Safety (Btrfs-safe swap)
echo "Creating 4GB temporary build-swap on /mnt..."
sudo touch /mnt/swapfile
sudo chattr +C /mnt/swapfile
sudo fallocate -l 4G /mnt/swapfile
sudo chmod 600 /mnt/swapfile
sudo mkswap /mnt/swapfile
sudo swapon /mnt/swapfile

# 5. Final Installation
echo "Starting Installation..."
# Added options to prevent timeouts and increase download speed
sudo nixos-install --root /mnt --flake ".#$FLAKE_ATTR" \
  --no-root-passwd \
  --option http-connections 40 \
  --option download-attempts 5 \
  --option download-buffer-size 500000000

echo "Installation Complete. You can now reboot."
