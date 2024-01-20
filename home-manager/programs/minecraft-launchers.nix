{config, pkgs, lib, ...}: {
  
  config = lib.mkIf config.rot.minecraft-launchers.enable  {
    home.packages = with pkgs; [
      # Launcher Java
      prismlauncher
    ];

    rot.persist = {
      home.directories = [
        ".local/share/PrismLauncher/"
      ];
    };
  };
}
