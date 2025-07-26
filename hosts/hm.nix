{
  inputs,
  pkgs,
  specialArgs,
  user ? "iynaix",
  ...
}: let
  mkHomeConfiguration = host:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs =
        specialArgs
        // {
          inherit host user;
          isNixOS = false;
          # isLaptop = host == "xps" || host == "framework";
          isLaptop = host == "omen";
        };

      modules = [
        inputs.nix-index-database.homeModules.nix-index
        ./${host}/home.nix # host specific home-manager configuration
        ../home-manager
        ../modules/home-manager
        ../overlays
      ];
    };
in {
  desktop = mkHomeConfiguration "desktop";
  omen = mkHomeConfiguration "omen";
  # NOTE: standalone home-manager doesn't make sense for VM config!
}
