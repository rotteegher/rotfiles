{lib, ...}: {
  options.custom = {
    backlight.enable = lib.mkEnableOption "Backlight";
    battery.enable = lib.mkEnableOption "Battery";
    wifi.enable = lib.mkEnableOption "Wifi";
    kbLayout = lib.mkOption {
      type = lib.types.str;
      default = "us";
    };
  };
}
