{
  config,
  lib,
  ...
}: let
  cfg = config.rot.obs-studio;
in {
  config = lib.mkIf cfg.enable {
    programs.obs-studio.enable = true;

    rot.persist = {
      home.directories = [
        ".config/obs-studio"
      ];
    };
  };
}

