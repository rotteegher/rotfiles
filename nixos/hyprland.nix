{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.custom.hyprland.enable {
  services.xserver.desktopManager.gnome.enable = lib.mkForce false;
  services.xserver.displayManager.lightdm.enable = lib.mkForce false;
  # services.xserver.displayManager.sddm.enable = lib.mkForce true;

  programs.hyprland =
    #   assert (
    #     lib.assertMsg (pkgs.hyprland.version == "0.39.1") "hyprland: updated, sync with hyprnstack?"
    #   );
    {
      enable = true;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

  # set here as legacy linux won't be able to set these
  hm.wayland.windowManager.hyprland.enable = true;

  # set which gpu `card` to use from /dev/dri/by-path 
  # use lspci | grep -E 'VGA|3D' to determine which gpu is which in /dev/dri/by-path

  # NOTE: use only by-path as the names like /dev/dri/card0 could change dynamically without notice after reboot
  environment.variables.WLR_DRM_DEVICES = lib.mkIf config.custom.hyprSelectGpu.enable (
    config.custom.hyprSelectGpu.device
  );

  # lock hyprland to 0.38.1 until workspace switching is resolved
  nixpkgs.overlays = [
    (_: prev: {
      hyprland =
        assert (
          lib.assertMsg (prev.hyprland.version == "0.39.1") "hyprland: updated, sync with hyprnstack?"
        );
        prev.hyprland.overrideAttrs (_: rec {
          version = "0.38.1";

          src = prev.fetchFromGitHub {
            owner = "hyprwm";
            repo = "hyprland";
            rev = "v${version}";
            hash = "sha256-6y422rx8ScSkjR1dNYGYUxBmFewRYlCz9XZZ+XrVZng=";
          };
        });
    })
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
