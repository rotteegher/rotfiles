{
  config,
  isLaptop,
  lib,
  pkgs,
  user,
  ...
}: let
  cfg = config.custom-nixos;
in {
  options.custom-nixos = {
    ### NIXOS LEVEL OPTIONS ###
    distrobox.enable = lib.mkEnableOption "distrobox";
    llm.enable = lib.mkEnableOption "large language model" // {default = false;};
    docker.enable = lib.mkEnableOption "docker" // {default = cfg.distrobox.enable;};
    surrealdb.enable = lib.mkEnableOption "docker" // {default = false;};
    hyprland = {
      enable = lib.mkEnableOption "hyprland (nixos)" // {default = true;};
    };
    keyd.enable = lib.mkEnableOption "keyd" // {default = isLaptop;};
    syncoid.enable = lib.mkEnableOption "syncoid";
    bittorrent = {
      enable = lib.mkEnableOption "Torrenting Applications";
      downloadDir = lib.mkOption {
        type = lib.types.str;
        default = "/persist/home/${user}/Downloads";
      };
    };
    vercel.enable = lib.mkEnableOption "Vercel Backups";
    virt-manager.enable = lib.mkEnableOption "virt-manager";
    flatpak.enable = lib.mkEnableOption "flatpak";
    steam.enable = lib.mkEnableOption "steam";
  };
}
