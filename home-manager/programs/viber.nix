{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.viber;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.viber
    ];

    custom.persist = {
      home.directories = [
        ".config/viber"
      ];
    };
  };
}
