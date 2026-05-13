{ ... }:
{
  flake.nixosModules.ghostty =
    { ... }:
    {
      home-manager.users.grey =
        { ... }:
        {
          programs.ghostty = {
            enable = true;
            settings = {
              background-opacity = "0.81";
            };
          };
        };
    };
}
