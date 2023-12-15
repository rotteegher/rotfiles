{
config,
pkgs,
lib,
...
}: {
  config = lib.mkIf config.rot.blender.enable  {
    home.packages = [ pkgs.blender ];

    rot.persist = {
      home.directories = [
        ".config/blender"
      ];
    };
  };
}

