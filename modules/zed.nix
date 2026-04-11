# Installs the pre-wrapped Zed package built in flake perSystem.packages.
{ flakePackages, ... }: {
  environment.systemPackages = [ flakePackages.zed ];
}
