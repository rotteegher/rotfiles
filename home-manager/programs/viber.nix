{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.rot.viber;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [ 
      pkgs.viber
    ];

    rot.persist = {
      home.directories = [
        # ".config/viber"
      ];
    };
  };
}

