{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.rot.deadbeef;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.deadbeef];

    rot.persist = {
      home.directories = [
        ".config/deadbeef"
      ];
    };
  };
}
