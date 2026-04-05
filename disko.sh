#!/usr/bin/env bash
# 1. Exit immediately if a command fails
set -e

# 2. Use a temporary directory
WORK_DIR=$(mktemp -d)
echo "Working in $WORK_DIR..."

# 3. Clone into the temp directory
git clone https://github.com/greyxp1/nixos-config.git "$WORK_DIR"
cd "$WORK_DIR"

# 4. Run the installer
sudo nix --experimental-features "nix-command flakes" run \
  'github:nix-community/disko/latest#disko-install' -- \
  --write-efi-boot-entries \
  --flake '.#nixos' \
  --disk nixos /dev/nvme0n1

# 5. Clean up
cd /
sudo rm -rf "$WORK_DIR"

# 6. Final destination
cd /etc/nixos || echo "Note: /etc/nixos may not exist until you reboot into your new system."
