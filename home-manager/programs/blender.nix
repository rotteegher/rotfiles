{
config,
pkgs,
lib,
...
}: {
  config = lib.mkIf config.rot.blender.enable  {
    home.packages = [
      pkgs.blender
      # pkgs.rot.goo-engine # TODO! currently trying to compile in packages/goo-engine/default.nix
    ];

    rot.persist = {
      home.directories = [
        ".config/blender"
      ];
    };
  };
}

