{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.custom.flatpak.enable {
    services.flatpak.enable = true;
    environment.systemPackages = [pkgs.flatpak pkgs.gnome-software];

    custom.persist = {
      home.directories = [
        ".local/share/flatpak"
        ".var"
      ];
    };
  };
}
