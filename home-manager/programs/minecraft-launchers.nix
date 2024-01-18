{config, pkgs, lib, ...}: {
  
  config = lib.mkIf config.rot.minecraft-launcher.enable  {
    home.packages = with pkgs; [
      # Launcher Java
      prismlauncher
    ];

    rot.persist = {
      home.directories = [
        ".local/share/PrismLauncher/"
        ".minecraft"
      ];
    };
  };
}
