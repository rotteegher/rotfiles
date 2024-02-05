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
      # Cuda support
      config.cudaSupport = true;
      # Permit insecure packages
      config.permittedInsecurePackages = [
       "openssl-1.1.1w" # make viber work
      ];
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
        inherit pkgs;

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
  all_hosts = lib.listToAttrs (map (host: {
    name =
      if isNixOS
      then host
      else "${user}@${host}";
    value = mkHost host;
  }) [ "desktop" "omen" ]);
in
  all_hosts
  # // {
  #   omen = all_hosts.omen // {config.custom-nixos.hyprland.enable = true;};
  # }
