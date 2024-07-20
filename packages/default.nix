{ pkgs, ... }:
let
  inherit (pkgs) lib callPackage;
  # injects a source parameter from nvfetcher
  # adapted from viperML's config
  # https://github.com/viperML/dotfiles/blob/master/packages/default.nix
  w =
    _callPackage: path: extraOverrides:
    let
      sources = pkgs.callPackages (path + "/generated.nix") { };
      firstSource = lib.head (lib.attrValues sources);
    in
    _callPackage (path + "/default.nix") (
      extraOverrides // { source = lib.filterAttrs (k: _: !(lib.hasPrefix "override" k)) firstSource; }
    );
in
{
  # boutique rust packages
  dotfiles-utils = callPackage ./dotfiles-utils { };

  # custom tela built with catppucin variant colors
  tela-dynamic-icon-theme = callPackage ./tela-dynamic-icon-theme { };

  distro-grub-themes-nixos = pkgs.callPackage ./distro-grub-themes-nixos { };

  minecraft-bedrock-server = w pkgs.callPackage ./minecraft-bedrock-server { };

  goo-engine = w pkgs.callPackage ./goo-engine;

  # custom version of pob with a .desktop entry, overwritten as a custom package
  # as the interaction with passthru is weird
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/games/path-of-building/default.nix
  rofi-themes = w pkgs.callPackage ./rofi-themes { };

  vv =
  assert (lib.assertMsg (!lib.hasAttr "vv" pkgs) "vv: vv is in nixpkgs");
  (w callPackage ./vv { });
}
