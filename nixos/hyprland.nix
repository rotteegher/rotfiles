{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.custom.hyprland.enable {
  services.xserver.desktopManager.gnome.enable = lib.mkForce false;
  services.xserver.displayManager.lightdm.enable = lib.mkForce false;
  # services.xserver.displayManager.sddm.enable = lib.mkForce true;

  # See https://nixos.org/manual/nixos/stable/release-notes#sec-release-23.11
  # Fcitx5 Doesn't Start When Using WM
  # As of NixOS 23.11 i18n.inputMethod.enabled no longer creates systemd services for fcitx5.
  # Instead it relies on XDG autostart files. If using a Window Manager (WM), such as Sway, you may need to add vvvTHISvvv to your NixOS configuration. 
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  programs.hyprland =
    {
      enable = true;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

  # set here as legacy linux won't be able to set these
  hm.wayland.windowManager.hyprland.enable = true;

  # lock hyprland to 0.38.1 until workspace switching is resolved
  nixpkgs.overlays = [ (_: _prev: { inherit (inputs.hyprland.packages.${pkgs.system}) hyprland; }) ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
