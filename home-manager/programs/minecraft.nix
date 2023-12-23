{config, pkgs, lib, ...}: {
  
  config = lib.mkIf config.rot.minecraft.enable  {
    home.packages = [ pkgs.prismlauncher ];

    rot.persist = {
      home.directories = [
        ".local/share/PrismLauncher/"
      ];
    };
  };
}
