{
  inputs,
  isNixOS,
  lib,
  self,
  user,
  ...
}: let
  mkHost = host: let
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
            # make sure to add overlays later !!!!
            # ../overlays
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                inherit extraSpecialArgs;

                users.${user} = {
                  imports = homeManagerImports ++ [inputs.impermanence.nixosModules.home-manager.impermanence];

                  # Let Home Manager install and manager itself
                  programs.home-manager.enable = true;
                };
              };
            }
            # alias for home-manager
            (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" user])
            inputs.impermanence.nixosModules.impermanence
            inputs.sops-nix.nixosModules.sops
          ];
        }
      else
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit extraSpecialArgs;
          pkgs = import inputs.nixpkgs {config.allowUnfree = true;};
          # make sure to add overlays later!!!
          modules = homeManagerImports;
           # ++ [../overlays];
        };
  in
    builtins.listToAttrs (map (host: {
      name = 
        if isNixOS
        then host
        else "${user}@#{host}";
        value = mkHost host;
    }) [ "desktop" "omen" ])
