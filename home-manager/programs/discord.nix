{
config,
pkgs,
lib,
...
}: {
  config = lib.mkIf config.rot.discord.enable  {
    home.packages = [ 
     (pkgs.writeShellApplication {
      name = "discord-vesktop";
      text = ''
        env -u NIXOS_OZONE_WL vencorddesktop --use-gl=desktop
      '';
    })
     (pkgs.makeDesktopItem {
        name = "discord-vesktop";
        exec =
          "env -u NIXOS_OZONE_WL vencorddesktop --use-gl=desktop";
        desktopName = "Discord-Vesktop";
        icon =
          "${pkgs.tela-circle-icon-theme}/share/icons/Tela-circle/scalable/apps/discord.svg";
      })
    ];

    rot.persist = {
      home.directories = [
        ".config/WebCord"
        ".config/discord"
        ".config/Vencord"
        ".config/VencordDesktop"
      ];
    };
  };
}

