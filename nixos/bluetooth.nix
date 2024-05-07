{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.bluetooth;
in {
  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;

    hm = hmCfg: {
      home.packages = with pkgs; [
        bluez
      ];
      # control media player over bluetooth
      services.mpris-proxy.enable = true;

      # add bluetooth audio icon to waybar
      custom.waybar.config.pulseaudio = lib.mkIf hmCfg.config.programs.waybar.enable {
        format-bluetooth = "  {volume}%";
      };
    };

    custom.persist = {
      root.directories = [
        "/var/lib/bluetooth"
      ];
    };
  };
}
