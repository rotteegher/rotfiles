{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.custom.blender.enable {
    home.packages = [
      # (lib.lowPrio pkgs.blender)
      pkgs.blender
      # pkgs.custom.goo-engine # TODO! compiled already
      (lib.meta.lowPrio pkgs.custom.goo-engine)

    ];

    custom.persist = {
      home.directories = [
        ".config/blender"
      ];
    };
  };
}
