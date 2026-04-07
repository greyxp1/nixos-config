#{ inputs, ... }: {
#  perSystem = { pkgs, system, ... }: {
#    packages.git-custom = inputs.wrappers.packages.${system}.git.wrap {
#      inherit pkgs;
#      settings = {
#        user = {
#          name = "greyxp1";
#          email = "greyxp999@gmail.com";
#        };
#        init.defaultBranch = "main";
#      };
#    };
#  };
#}


{ inputs, pkgs, ... }:

{
  imports = [
    inputs.wrappers.nixosModules.default
  ];
  config.wrappers.g.git = {
    enable = true;
    package = pkgs.git;
    config = {
      user = {
        name = "greyxp1";
        email = "greyxp999@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };
}
