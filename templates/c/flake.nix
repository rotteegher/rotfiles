{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    fenix.url = "github:nix-community/fenix";
  };

  outputs = {
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    devShells =
      forEachSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              # https://devenv.sh/reference/options/
              dotenv.disableHint = true;

              packages = with pkgs; [
                gnumake
                cmake
                gcc
                libgcc
                git
                glibc
                zlib
                cxxtools
                subversion
              ];

              # setup openssl for reqwest (if used)
              env = {
                PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
              };

              languages.c = {
                enable = true;
              };
              languages.python = {
               enable = true;
               package = pkgs.python3.withPackages (ps:
                 with ps; [
                   flake8
                   black
                 ]);
               venv.enable = true;
              };
            }
          ];
        };
      });
  };
}
