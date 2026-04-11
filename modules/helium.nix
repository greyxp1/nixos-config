# Installs the pre-wrapped Helium package built in flake perSystem.packages.
{ flakePackages, ... }: {
  environment.systemPackages = [ flakePackages.helium ];
}
