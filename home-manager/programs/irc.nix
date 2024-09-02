{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.irc;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.senpai];

    custom.persist = {
      home.directories = [
        ".config/senpai"
      ];
    };
  };
}
