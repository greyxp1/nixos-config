### Install script: 

```bash
bash <(curl -s https://raw.githubusercontent.com/greyxp1/nixos-config/main/install.sh) greyxp1/nixos-config /dev/sda
```

### disko-install:
```bash
sudo nix --experimental-features "nix-command flakes" run 'github:nix-community/disko/latest#disko-install' -- --write-efi-boot-entries --flake github:greyxp1/nixos-config#nixos --disk main /dev/nvme0n1
```

### Manual Installation:
```bash
sudo -i
lsblk
cfdisk /dev/vda

gpt labels

1G type: EFI
4G type: swap
remaining space, type: Linux Filesystem
```

```bash
mkfs.ext4 -L nixos /dev/nvme0n1p3
mkswap -L swap /dev/nvme0n1p2
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
```

```bash
mount /dev/nvme0n1p3 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
swapon /dev/nvme0n1p2
```

```bash
nixos-generate-config --root /mnt
cd /mnt/etc/nixos/
```

```bash
nixos-install

## type your password
nixos-enter --root /mnt -c 'passwd tony'
reboot
```
