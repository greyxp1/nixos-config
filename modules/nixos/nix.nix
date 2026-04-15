{ ... }: {
  # Host-specific substituters/keys are appended via extra-substituters in
  # each host's host.nix so this file stays portable.
  flake.nixosModules.nix-config = { ... }: {
    nix.settings = {
      trusted-users         = [ "root" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
}
