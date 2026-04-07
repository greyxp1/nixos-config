#!/usr/bin/env bash
set -e

# 1. Clone your config
git clone https://github.com/greyxp1/nixos-config.git
cd nixos-config

# 2. Run Disko to partition and mount the REAL disk
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- --mode destroy,format,mount \
  --yes-wipe-all-disks \
  ./disko-config.nix \
  --argstr device "/dev/nvme0n1"

# 3. Attempt Installation
echo "Starting NixOS installation..."
set +e # Temporarily allow errors so we can catch the OOM crash
sudo nixos-install --root /mnt --flake .#nixos
INSTALL_EXIT_CODE=$?
set -e

# 4. Logic: If it failed due to Out of Memory (Exit code 137 or general failure)
if [ $INSTALL_EXIT_CODE -ne 0 ]; then
    echo "Installation failed or was killed (Exit code: $INSTALL_EXIT_CODE). Checking for OOM..."

    # Create 4GB swapfile ON THE DISK (/mnt) to provide extra RAM
    echo "Creating 4GB emergency swapfile on /mnt..."
    sudo dd if=/dev/zero of=/mnt/swapfile bs=1M count=4096
    sudo chmod 600 /mnt/swapfile
    sudo mkswap /mnt/swapfile
    sudo swapon /mnt/swapfile

    echo "Retrying installation with swap enabled..."
    sudo nixos-install --root /mnt --flake .#nixos
else
    echo "Installation finished successfully on the first try."
fi
