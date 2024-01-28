{
  description = "Rotteegher's rotfiles, - are configuration dotfiles which are managed via NixOS and home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv.url = "github:cachix/devenv";

    impermanence.url = "github:nix-community/impermanence";

    hyprland = {
      url = "github:hyprwm/Hyprland";
      # inputs.nixpkgs.follows = "nixpkgs"; # commented twice
    };

    hyprgrass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };

    xdph = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # flake-utils is unnecessary
  # https://ayats.org/blog/no-flake-utils/
  outputs = inputs @ {
    nixpkgs,
    self,
    ...
  }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs ["x86_64-linux"] (system: function nixpkgs.legacyPackages.${system});
    commonInherits = {
      inherit (nixpkgs) lib;
      inherit self inputs nixpkgs;
      user = "rot";
      system = "x86_64-linux";
    };
  in {
    nixosConfigurations = 
      import ./hosts (commonInherits // {isNixOS = true;})
      // (import ./hosts/iso (commonInherits // {isNixOS = true;}));


    homeConfigurations = import ./hosts (commonInherits // {isNixOS = false;});

    # devenv for working on rotfiles, provides rust environment
    devShells = forAllSystems (pkgs: {
      default = inputs.devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          ({pkgs, ...}: {
            # devenv configuration
            packages = [pkgs.alejandra];

            languages.rust = {
              enable = true;
              channel = "stable";
            };
          })
        ];
      };
    });

    packages = forAllSystems (
      pkgs: (import ./packages {inherit pkgs inputs;})
    );

    inherit self;

    # templates for devenv
    templates = import ./templates;
  };
}
