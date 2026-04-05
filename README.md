### Install script: 

```bash
bash <(curl -s https://raw.githubusercontent.com/greyxp1/nixos-config/main/install.sh) greyxp1/nixos-config /dev/nvme0n1
```

### disko-install:

#### Option 1:
```bash
bash <(curl -s https://raw.githubusercontent.com/greyxp1/nixos-config/main/disko.sh)
#### Option 2:
```bash
git clone https://github.com/greyxp1/nixos-config.git
```
```bash
cd nixos-config
```
```bash
sudo nix --experimental-features "nix-command flakes" run 'github:nix-community/disko/latest#disko-install' -- --write-efi-boot-entries --flake '.#nixos' --disk nixos /dev/nvme0n1
```

---

### Manual Installation

#### Option 1: UEFI

1. **Partitioning**
   ```bash
   cfdisk /dev/nvme0n1
   # Select 'gpt'
   # New -> 1G -> Type: EFI System
   # New -> 4G -> Type: Linux swap
   # New -> Remaining -> Type: Linux Filesystem
   # Write -> quit
   ```

2. **Formatting & Mounting**
   ```bash
   mkfs.fat -F 32 -n boot /dev/nvme0n1p1
   mkswap -L swap /dev/nvme0n1p2
   mkfs.ext4 -L nixos /dev/nvme0n1p3

   mount /dev/disk/by-label/nixos /mnt
   mount --mkdir /dev/disk/by-label/boot /mnt/boot
   swapon /dev/nvme0n1p2
   ```

3. **Configuration**
   ```bash
   nixos-generate-config --root /mnt
   vim /mnt/etc/nixos/configuration.nix
   ```
   
   ```bash
   { config, pkgs, ... }: {
     imports = [
       ./hardware-configuration.nix
     ];

     boot.loader.systemd-boot.enable = true;
     boot.loader.efi.canTouchEfiVariables = true;
   
     networking.hostName = "nixos";
     networking.networkmanager.enable = true;

     users.users.grey = {
       isNormalUser = true;
       extraGroups = [ "networkmanager" "wheel" ];
       initialPassword = "password";
     };

     environment.systemPackages = with pkgs; [
       git
       vim
       wget
       curl
     ];

     system.stateVersion = "23.11";
   }
   ```

4. **Installation**
   ```bash
   nixos-install
   shutdown now
   ```

---

#### Option 2: BIOS

1. **Partitioning**
   ```bash
   cfdisk /dev/nvme0n1
   # Select 'gpt'
   # New -> 1M -> Type: BIOS boot
   # New -> 4G -> Type: Linux swap
   # New -> Remaining -> Type: Linux filesystem
   # Write -> quit
   ```

2. **Formatting & Mounting**
   ```bash
   mkfs.ext4 -L nixos /dev/nvme0n1p3
   mkswap -L swap /dev/nvme0n1p2
   swapon /dev/nvme0n1p2
   mount /dev/nvme0n1p3 /mnt
   ```

3. **Configuration**
   ```bash
   nixos-generate-config --root /mnt
   vim /mnt/etc/nixos/configuration.nix
   ```
   
   ```bash
   { config, pkgs, ... }: {
     imports = [
       ./hardware-configuration.nix
     ];

     boot.loader.grub.enable = true;
     boot.loader.grub.device = "/dev/nvme0n1";
   
     networking.hostName = "nixos";
     networking.networkmanager.enable = true;

     users.users.grey = {
       isNormalUser = true;
       extraGroups = [ "networkmanager" "wheel" ];
       initialPassword = "password";
     };

     environment.systemPackages = with pkgs; [
       git
       vim
       wget
       curl
     ];

     system.stateVersion = "23.11";
   }
   ```

4. **Installation**
   ```bash
   nixos-install
   shutdown now
   ```
