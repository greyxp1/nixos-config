#!/usr/bin/env bash
set -euo pipefail

DISK="/dev/nvme0n1"
FLAKE_ATTR="nixos"

# 1. Prepare Workspace
rm -rf nixos-config
git clone https://github.com/greyxp1/nixos-config.git
cd nixos-config

# 3. Disk Setup
echo "Running Disko..."
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- --mode destroy,format,mount \
  --yes-wipe-all-disks \
  ./disko-config.nix \
  --argstr device "$DISK"

# 5. Final Installation
echo "Starting Installation..."
sudo nixos-install --root /mnt --flake ".#$FLAKE_ATTR" --no-root-passwd

echo "Installation Complete. You can now reboot."
..
