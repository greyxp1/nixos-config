### Run this to install: 

```bash
bash <(curl -s https://raw.githubusercontent.com/greyxp1/nixos-config/main/install.sh) greyxp1/nixos-config /dev/sda
```

```bash
sudo nix run 'github:nix-community/disko/latest#disko-install' -- --flake github:greyxp1/nixos-config#nixos --disk main /dev/sda
```
