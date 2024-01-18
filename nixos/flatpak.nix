
{pkgs, lib, config, ...}: {
  
  config = lib.mkIf config.rot-nixos.flatpak.enable {
    services.flatpak.enable = true;
    environment.systemPackages = [ pkgs.flatpak pkgs.gnome.gnome-software];

    rot-nixos.persist = {
      home.directories = [
        ".local/share/flatpak"
        ".var"
      ];
    };
  };
}
