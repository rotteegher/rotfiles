{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.custom.discord.enable {
    home.packages = [
      pkgs.zoom-us
      (pkgs.writeShellApplication {
        name = "discord-vesktop";
        text = ''
          env -u NIXOS_OZONE_WL vesktop --use-gl=desktop
        '';
      })
      (pkgs.makeDesktopItem {
        name = "discord-vesktop";
        exec = "env -u NIXOS_OZONE_WL vesktop --use-gl=desktop";
        desktopName = "Discord-Vesktop";
        icon = "${pkgs.tela-circle-icon-theme}/share/icons/Tela-circle/scalable/apps/discord.svg";
      })

      pkgs.discord
    ];

    custom.persist = {
      home.directories = [
        ".config/discord"
        ".config/vesktop"
        ".config/VencordDesktop"
      ];
    };
  };
}
