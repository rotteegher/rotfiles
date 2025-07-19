{
  inputs,
  isNixOS,
  lib,
  self,
  system,
  user,
  ...
}: let
  mkHost = host: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    extraSpecialArgs = {
      inherit self inputs isNixOS host user;
      isLaptop = host == "omen";
    };
    homeManagerImports = [
      inputs.nix-index-database.hmModules.nix-index
      ./${host}/home.nix
      ../home-manager
      ../modules/home-manager
    ];
  in
    if isNixOS
    then
      lib.nixosSystem {
        specialArgs = extraSpecialArgs;

        modules = [
          ./${host} # host specific configuration
          ./${host}/hardware.nix # host specific hardware configuration
          ../nixos
          ../modules/nixos
          ../overlays
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              inherit extraSpecialArgs;

              users.${user} = {
                imports = homeManagerImports ++ [inputs.impermanence.nixosModules.home-manager.impermanence];

                # Let Home Manager install and manage itself
                programs.home-manager.enable = true;
              };
            };
          }
          # alias for home-manager
          (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" user])
          inputs.impermanence.nixosModules.impermanence
        ];
      }
    else
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit extraSpecialArgs pkgs;

        modules = homeManagerImports ++ [../overlays];
      };
in
  builtins.listToAttrs (map (host: {
    name =
      if isNixOS
      then host
      else "${user}@#{host}";
    value = mkHost host;
  }) [ "desktop" "omen" ])
