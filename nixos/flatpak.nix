{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.custom-nixos.flatpak.enable {
    services.flatpak.enable = true;
    environment.systemPackages = [pkgs.flatpak pkgs.gnome.gnome-software];

    custom-nixos.persist = {
      home.directories = [
        ".local/share/flatpak"
        ".var"
      ];
    };
  };
}
