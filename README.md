### Installation: 

```bash
bash <(curl -sL https://raw.githubusercontent.com/greyxp1/nixos-config/main/install.sh) --host main-pc
```

### To rebuild the system:

```bash
cd ~/nixos-config/ && git pull
```

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#main-pc
```

### To update the system:

```bash
nix flake update --flake ~/nixos-config
```

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#main-pc
```

### To build the flake.lock file in wsl:

```bash
wsl -d NixOS
```

```bash
nix-shell -p git --run "nix --extra-experimental-features 'nix-command flakes' flake lock"
```
