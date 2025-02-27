{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.kiwix;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      # pkgs.kiwix
    ];

    custom.persist = {
      home.directories = [
        ".local/share/kiwix"
      ];
    };
  };
}

