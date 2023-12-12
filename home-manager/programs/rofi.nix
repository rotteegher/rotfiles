{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
  };

  home.packages = with pkgs; [rofi-power-menu];

  xdg.configFile = {
    "rofi/rofi-wifi-menu" = lib.mkIf config.rot.wifi.enable {
      source = ./rofi-wifi-menu.sh;
    };

    "rofi/config.rasi".text = ''
      @theme "~/.cache/wallust/rofi.rasi"
    '';
  };

  rot.wallust.entries."rofi.rasi" = {
    enable = config.programs.rofi.enable;
    text = builtins.readFile ./rofi-rot.rasi;
    target = "~/.cache/wallust/rofi.rasi";
  };
}
