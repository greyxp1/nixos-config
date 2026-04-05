#!/usr/bin/env bash
set -e

sudo nix --experimental-features "nix-command flakes" run \
  'github:nix-community/disko/latest#disko-install' -- \
  --flake 'github:yourusername/nixos-config#universal' \
  --disk nixos /dev/nvme0n1
