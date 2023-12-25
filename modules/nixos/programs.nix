{
  config,
  isLaptop,
  lib,
  ...
}: let
  cfg = config.rot-nixos;
in {
  options.rot-nixos = {
    ### NIXOS LEVEL OPTIONS ###
    distrobox.enable = lib.mkEnableOption "distrobox";
    docker.enable = lib.mkEnableOption "docker" // {default = cfg.distrobox.enable;};
    hyprland.enable = lib.mkEnableOption "hyprland (nixos)" // {default = true;};
    kanata.enable = lib.mkEnableOption "kanata" // {default = isLaptop;};
    sops.enable = lib.mkEnableOption "sops" // {default = true;};
    syncoid.enable = lib.mkEnableOption "syncoid";
    bittorrent.enable = lib.mkEnableOption "Torrenting Applications";
    vercel.enable = lib.mkEnableOption "Vercel Backups";
    virt-manager.enable = lib.mkEnableOption "virt-manager";
    steam.enable = lib.mkEnableOption "steam";
  };
}
