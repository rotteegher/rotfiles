{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.custom.minecraft-launchers.enable {
    home.packages = with pkgs; [
      # Launcher Java
      prismlauncher
      cubiomes-viewer
      jdk8
      jre8
    ];

    custom.persist = {
      home.directories = [
        ".local/share/PrismLauncher/"
      ];
    };
  };
}
