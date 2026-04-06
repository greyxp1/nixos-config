#!/usr/bin/env bash
set -e

git clone https://github.com/greyxp1/nixos-config.git
cd nixos-config

sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- --mode destroy,format,mount \
  --yes-wipe-all-disks \
  ./disko-config.nix \
  --argstr device "/dev/nvme0n1"

sudo nixos-install --root /mnt --flake .#nixos
