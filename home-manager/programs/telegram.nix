{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.custom.telegram.enable {
    home.packages = [pkgs.telegram-desktop];

    # fix mimetype associations
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/tg=userapp-Telegram" = "telegramdesktop.desktop";
      };
    };

    custom.persist = {
      home.directories = [
        ".local/share/TelegramDesktop"
      ];
    };
  };
}
