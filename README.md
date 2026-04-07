### Installation: 

1. **View content of the script**
```bash
curl -L https://raw.githubusercontent.com/greyxp1/nixos-config/main/install.sh
```

2. **Run the script**
```bash
curl -s https://raw.githubusercontent.com/greyxp1/nixos-config/main/install.sh | bash
```

### To rebuild the system:

```bash
cd ~/nixos-config/ && git pull
```

```bash
sudo nixos-rebuild switch --flake ~/nixos-config/
```

### To build the flake.lock file in wsl:

```bash
wsl -d NixOS
```

```bash
nix-shell -p git --run "nix --extra-experimental-features 'nix-command flakes' flake lock"
```
