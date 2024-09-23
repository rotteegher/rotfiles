{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.deadbeef;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.deadbeef pkgs.audacious];

    custom.persist = {
      home.directories = [
        ".config/deadbeef"
      ];
    };
  };
}
