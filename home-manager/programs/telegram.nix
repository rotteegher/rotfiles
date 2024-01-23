{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.rot.telegram.enable {
    home.packages = [pkgs.telegram-desktop];

    # fix mimetype associations
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/tg=userapp-Telegram" = "telegramdesktop.desktop";
      };
    };

    rot.persist = {
      home.directories = [
        ".local/share/TelegramDesktop"
      ];
    };
  };
}
