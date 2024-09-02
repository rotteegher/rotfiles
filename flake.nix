{
  description = "Rotteegher's rotfiles, - are configuration dotfiles which are managed via NixOS and home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musnix = {
      url = "github:musnix/musnix";
    };

    hyprland.url = "github:hyprwm/hyprland/v0.38.1";

    devenv.url = "github:cachix/devenv";

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprgrass = {
      url = "github:horriblename/hyprgrass";
    };

    wfetch = {
      url = "github:iynaix/wfetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  # flake-utils is unnecessary
  # https://ayats.org/blog/no-flake-utils/
  outputs =
    inputs@{ nixpkgs, self, ... }:
    let
      system = "x86_64-linux";
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system: function nixpkgs.legacyPackages.${system});
      commonArgs = {
        inherit (nixpkgs) lib;
        inherit self inputs nixpkgs;
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        specialArgs = {
          inherit self inputs;
        };
      };
    in
    {
      nixosConfigurations = (import ./hosts/nixos.nix commonArgs) // (import ./hosts/iso commonArgs);

      homeConfigurations = import ./hosts/hm.nix commonArgs;

      # devenv for working on rotfiles, provides rust environment
      devShells = forAllSystems (pkgs: {
        default = import ./devenv.nix {
          inherit inputs;
          inherit (pkgs) system;
        };
      });

      packages = forAllSystems (pkgs: (import ./packages { inherit pkgs inputs; }));

      # templates for devenvs
      templates = import ./templates;
    };
}
