{
  lib,
  config,
  ...
}: {
  options.rot-nixos = {
    nvidia.enable = lib.mkEnableOption "Nvidia GPU";
    hdds = {
      enable = lib.mkEnableOption "Desktop HDDs";
      stsea3tb = lib.mkEnableOption "stsea-barra" // {default = config.rot-nixos.hdds.enable;}; #  Seagate Barracuda 3TB ST3000DM007
      wdc1tb = lib.mkEnableOption "wdc-blue" // {default = config.rot-nixos.hdds.enable;}; # WDC Blue 1TB WD10SPZX
      windows = lib.mkEnableOption "Windows" // {default = config.rot-nixos.hdds.enable;};
    };

    zfs = {
      enable = lib.mkEnableOption "zfs" // {default = true;};
      encryption = lib.mkEnableOption "zfs encryption" // {default = false;}; # default was true at iynaix config
      snapshots = lib.mkEnableOption "zfs snapshots" // {default = true;};
    };
  };
}
