{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.hotspot;
in {
  config = lib.mkIf (config.hm.custom.wifi.enable && cfg.enable) {
    environment.systemPackages = [ pkgs.linux-wifi-hotspot pkgs.hostapd ];

    environment.etc."dnsmasq.d/create_ap.conf".text = ''
      dhcp-range=192.168.12.100,192.168.12.254,12h
      dhcp-host=64:c6:d2:4b:e8:1f,192.168.12.200
    '';

    # Enable WIFi Hotspot
    services.create_ap = {
      enable = true;
      settings = {
        INTERNET_IFACE = cfg.internet_iface;
        WIFI_IFACE = cfg.wifi_iface;
        SSID = cfg.ssid;
        PASSPHRASE = cfg.passphrase;
        DNSMASQ_CONF_FILE = "/etc/dnsmasq.d/create_ap.conf";
      };
    };
  };
}
