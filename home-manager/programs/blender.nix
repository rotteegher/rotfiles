{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.custom.blender.enable {
    home.packages = [
      pkgs.blender
      # pkgs.custom.goo-engine # TODO! currently trying to compile in packages/goo-engine/default.nix
    ];

    custom.persist = {
      home.directories = [
        ".config/blender"
      ];
    };
  };
}
