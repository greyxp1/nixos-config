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


{ config, lib, wlib, pkgs, ... }:

{
  imports = [
    wlib.wrapperModules.git
  ];
  config.wrappers.g.git = {
    enable = true;
    package = pkgs.git;
    inner = {
      user = {
        name = "greyxp1";
        email = "greyxp999@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };
}
