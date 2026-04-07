#!/usr/bin/env bash
set -e

# 1. Clone your config
git clone https://github.com/greyxp1/nixos-config.git
cd nixos-config

# 2. Run Disko
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- --mode destroy,format,mount \
  --yes-wipe-all-disks \
  ./disko-config.nix \
  --argstr device "/dev/nvme0n1"

# 3. Attempt Installation
echo "Starting NixOS installation..."
set +e
sudo nixos-install --root /mnt --flake .#nixos
INSTALL_EXIT_CODE=$?
set -e

# 4. Error Handling: Btrfs-compatible Swap
if [ $INSTALL_EXIT_CODE -ne 0 ]; then
    echo "Installation failed (Exit code: $INSTALL_EXIT_CODE). Creating Btrfs-safe swap..."

    # Ensure we are working on the actual disk
    sudo touch /mnt/swapfile
    sudo chattr +C /mnt/swapfile          # Disable CoW (Required for Btrfs swap)
    sudo fallocate -l 2G /mnt/swapfile    # 2GB is safer for smaller VM disks
    sudo chmod 600 /mnt/swapfile
    sudo mkswap /mnt/swapfile
    sudo swapon /mnt/swapfile

    echo "Retrying installation with swap enabled..."
    sudo nixos-install --root /mnt --flake .#nixos
else
    echo "Installation finished successfully."
fi
