{
  lib,
  config,
  ...
}: {
  options.rot-nixos = {
    nvidia.enable = lib.mkEnableOption "Nvidia GPU";
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
