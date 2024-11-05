{
  config,
  lib,
  pkgs,
  user,
  ...
}:
lib.mkIf config.custom.jellyfin.enable {
  services.jellyfin = {
    enable = false;
    openFirewall = true;
    user = "${user}";
  };
  environment.systemPackages = with pkgs; [
    # jellyfin
    # jellyfin-web
    # jellyfin-ffmpeg
  ];
  networking.firewall.allowedTCPPorts = [ 8096 ];
  networking.firewall.allowedUDPPorts = [ 8096 ];

  custom.persist = {
    root.directories = [ "/var/lib/jellyfin" ];
  };
}
