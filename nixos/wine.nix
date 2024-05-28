{
  lib,
  config,
  pkgs,
  ...
}: lib.mkIf config.custom.wine.enable {
  environment.systemPackages = with pkgs; [
    # support both 32- and 64-bit applications
    # wineWowPackages.stable

    # support 32-bit only
    # wine

    # support 64-bit only
    # (wine.override { wineBuild = "wine64"; })

    # support 64-bit only
    # wine64

    # wine-staging (version with experimental features)
    wineWowPackages.staging

    # winetricks (all versions)
    winetricks

    # native wayland support (unstable)
    wineWowPackages.waylandFull
  ];

  custom.persist = {
    home.directories = [
      ".wine"
    ];
  };
}
