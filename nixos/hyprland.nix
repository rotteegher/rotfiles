{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-nixos.hyprland;
in {
  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.gnome.enable = lib.mkForce false;
    services.xserver.displayManager.lightdm.enable = lib.mkForce false;
    # services.xserver.displayManager.sddm.enable = lib.mkForce true;

    # locking with swaylock
    security.pam.services.swaylock = {
      text = "auth include login";
    };

    programs.bash.shellAliases = {H = "Hyprland";};

    programs.hyprland = {
      enable = true;
      # portalPackage = inputs.xdph.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

    # set here as legacy linux won't be able to set these
    hm.wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      # package = pkgs.hyprland; # lock to stable version
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
