#!/usr/bin/env bash
set -e

git clone https://github.com/greyxp1/nixos-config.git /tmp/nixos-config
cd /tmp/nixos-config

sudo nix --experimental-features "nix-command flakes" run \
  'github:nix-community/disko/latest#disko-install' -- \
  --write-efi-boot-entries \
  --flake '.#nixos' \
  --disk nixos /dev/nvme0n1

sudo mkdir -p /mnt/etc/nixos
sudo cp -r /tmp/nixos-config/. /mnt/etc/nixos/
sudo rm -rf /tmp/nixos-config
