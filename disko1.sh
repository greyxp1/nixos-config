#!/usr/bin/env bash
set -e
sudo nix --experimental-features "nix-command flakes" run \
  'github:nix-community/disko/latest#disko-install' -- \
  --write-efi-boot-entries \
  --flake "github:greyxp1/nixos-config#nixos" \
  --disk nixos /dev/nvme0n1 \
  --option warn-dirty false \
  --option commit-lockfile-summary "false"
