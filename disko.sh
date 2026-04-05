git clone https://github.com/greyxp1/nixos-config.git

cd nixos-config

sudo nix --experimental-features "nix-command flakes" run \
  'github:nix-community/disko/latest#disko-install' -- \
  --write-efi-boot-entries \
  --flake '.#nixos' \
  --disk nixos /dev/nvme0n1

cd ..

rm -rf nixos-config

cd /etc/nixos
