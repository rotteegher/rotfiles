{
  inputs,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
  # use latest stable rust
  rustPlatform = let
    inherit (inputs.fenix.packages.${pkgs.system}.stable) toolchain;
  in
    pkgs.makeRustPlatform {
      cargo = toolchain;
      rustc = toolchain;
    };
  # injects a source parameter from nvfetcher
  # adapted from viperML's config
  # https://github.com/viperML/dotfiles/blob/master/packages/default.nix
  w = _callPackage: path: extraOverrides: let
    sources = pkgs.callPackages (path + "/generated.nix") {};
    firstSource = builtins.head (builtins.attrValues sources);
  in
    _callPackage (path + "/default.nix") (extraOverrides
      // {source = lib.filterAttrs (k: _: !(lib.hasPrefix "override" k)) firstSource;});
in {
  # rust dotfiles utils
  dotfiles-utils =
    pkgs.callPackage ./dotfiles-utils {inherit rustPlatform;};

  minecraft-bedrock-server = w pkgs.callPackage ./minecraft-bedrock-server {};

  # goo-engine =
  #   pkgs.callPackage ./goo-engine;

  # custom version of pob with a .desktop entry, overwritten as a custom package
  # as the interaction with passthru is weird
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/games/path-of-building/default.nix
  rofi-themes = w pkgs.callPackage ./rofi-themes {};

  vv = w pkgs.callPackage ./vv {};
}
