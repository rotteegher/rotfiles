{
  lib,
  config,
  ...
}: {
  options.rot-nixos = {
    nvidia.enable = lib.mkEnableOption "Nvidia GPU";
    bluetooth.enable = lib.mkEnableOption "Bluetooth" // {default = false;};
    hotspot = {
      enable = lib.mkEnableOption "WiFI Broadcast HotSpot" // {default = false;};
      internet_iface = lib.mkOption {
        type = lib.types.str;
        default = "eno1";
        description = "Interface to get connection from";
      };
      wifi_iface = lib.mkOption {
        type = lib.types.str;
        default = "wlp2s0";
        description = "Interface to broadcast WiFi hotspot from";
      };
      ssid = lib.mkOption {
        type = lib.types.str;
        default = "RotWiFi";
        description = "Hotspot name";
      };
      passphrase = lib.mkOption {
        type = lib.types.str;
        default = "AAAzzz123123";
        description = "Hotspot password";
      };
    };
    hdds = {
      enable = lib.mkEnableOption "Desktop HDDs" // {default = false;};
      stsea3tb = lib.mkEnableOption "stsea-barra" // {default = false;}; #  Seagate Barracuda 3TB ST3000DM007
      wdc1tb = lib.mkEnableOption "wdc-blue" // {default = false;}; # WDC Blue 1TB WD10SPZX
      windows = lib.mkEnableOption "Windows" // {default = false;};
    };

    zfs = {
      enable = lib.mkEnableOption "zfs" // {default = true;};
      encryption = lib.mkEnableOption "zfs encryption" // {default = false;}; # default was true at iynaix config
      snapshots = lib.mkEnableOption "zfs snapshots" // {default = true;};
    };
  };
}
