{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.rot.vlc;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.vlc];

    rot.persist = {
      home.directories = [
        ".config/vlc"
      ];
    };
  };
}

