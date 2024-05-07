{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.custom.insomnia.enable {
    home.packages = [
      pkgs.insomnia
      (pkgs.writeShellApplication {
        name = "insomnia-wl";
        text = ''
          env -u NIXOS_OZONE_WL insomnia --use-gl=desktop
        '';
      })
      (pkgs.makeDesktopItem {
        name = "insomnia-wl";
        exec = "env -u NIXOS_OZONE_WL insomnia --use-gl=desktop";
        desktopName = "Insomnia [NIXOS_OZONE_WL]";
        icon = "${pkgs.tela-circle-icon-theme}/share/icons/Tela-circle-dark/scalable/apps/insomnia.svg";
      })
    ];

    custom.persist = {
      home.directories = [".config/Insomnia"];
    };
  };
}
