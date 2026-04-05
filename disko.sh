#!/usr/bin/env bash
set -e

sudo nix --experimental-features "nix-command flakes" run \
  'github:nix-community/disko/latest#disko-install' -- \
  --flake 'github:greyxp1/nixos-config#nixos' \
  --write-efi-boot-entries \
  --disk nixos /dev/nvme0n1
