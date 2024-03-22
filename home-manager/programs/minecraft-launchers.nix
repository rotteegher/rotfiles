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
      jdk21
      jdt-language-server
    ];

    custom.persist = {
      home.directories = [
        ".local/share/PrismLauncher/"
      ];
    };
  };
}
