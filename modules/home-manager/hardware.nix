{lib, ...}: {
  options.custom = {
    backlight.enable = lib.mkEnableOption "Backlight";
    battery.enable = lib.mkEnableOption "Battery";
    wifi.enable = lib.mkEnableOption "Wifi";
    mouse_sensitivity = lib.mkOption {
      type = lib.types.float;
      default = 0.0;
    };
    kbLayout = lib.mkOption {
      type = lib.types.str;
      default = "us";
    };
  };
}
