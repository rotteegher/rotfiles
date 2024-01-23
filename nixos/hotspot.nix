{
  config,
  lib,
  ...
}: let
  cfg = config.rot-nixos.hotspot;
in {
  config = lib.mkIf cfg.enable {
    # Enable WIFi Hotspot
    services.create_ap = {
      enable = true;
      settings = {
        INTERNET_IFACE = cfg.internet_iface;
        WIFI_IFACE = cfg.wifi_iface;
        SSID = cfg.ssid;
        PASSPHRASE = cfg.passphrase;
      };
    };
  };
}
