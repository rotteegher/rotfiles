{
  config,
  isLaptop,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.custom;
in
{
  options.custom = {
    ### NIXOS LEVEL OPTIONS ###
    distrobox.enable = lib.mkEnableOption "distrobox";
    llm.enable = lib.mkEnableOption "large language model" // {
      default = false;
    };
    docker.enable = lib.mkEnableOption "docker" // {
      default = cfg.distrobox.enable;
    };
    surrealdb.enable = lib.mkEnableOption "docker" // {
      default = false;
    };
    jellyfin.enable = lib.mkEnableOption "jellyfin" // {
      default = false;
    };
    hyprland = {
      enable = lib.mkEnableOption "hyprland (nixos)" // {
        default = true;
      };
    };
    keyd.enable = lib.mkEnableOption "keyd" // {
      default = isLaptop;
    };
    syncoid.enable = lib.mkEnableOption "syncoid";
    bittorrent = {
      enable = lib.mkEnableOption "Torrenting Applications";
      downloadDir = lib.mkOption {
        type = lib.types.str;
        default = "/home/${user}/_CURRENT/";
      };
    };
    flatpak.enable = lib.mkEnableOption "flatpak";
    steam.enable = lib.mkEnableOption "steam";

    shell = {
      packages = lib.mkOption {
        type = with lib.types; attrsOf (either str package);
        default = { };
        description = "Attrset of extra shell packages to install and add to pkgs.custom overlay, strings will be converted to writeShellApplication.";
      };

      finalPackages = lib.mkOption {
        type = with lib.types; attrsOf package;
        readOnly = true;
        default = lib.mapAttrs (
          name: pkg:
          if lib.isString pkg then
            pkgs.writeShellApplication {
              inherit name;
              text = pkg;
            }
          else
            pkg
        ) config.custom.shell.packages;
        description = "Extra shell packages to install after all entries have been converted to packages.";
      };
    };
  };
}
