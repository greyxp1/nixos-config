### Installation: 

1. **View the script**
```bash
curl -L https://raw.githubusercontent.com/greyxp1/nixos-config/main/disko.sh
```

2. **Run the script**
```bash
curl -s https://raw.githubusercontent.com/greyxp1/nixos-config/main/disko.sh | bash
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
