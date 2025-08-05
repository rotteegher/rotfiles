{
  config,
  user,
  pkgs,
  lib,
  ...
}: let
  cfg = config.custom.fileshare;
in 
(lib.mkIf config.custom.sops.enable {
  sops.secrets.fileshare_adminpass.owner = user;

  # services.cockpit = lib.mkIf cfg.enable {
  #   enable = true;
  #   openFirewall = true;
  #   port = 8082;
  #   # settings = {
  #   #   "WebServce" = {
  #   #     "Origins" = [];
  #   #   };
  #   # };
  # };

  networking.firewall.allowedTCPPorts = [ 8082 ];
  networking.firewall.allowedUDPPorts = [ 8082 ];

  # custom.persist = {
  #   root.directories = ["/var/lib/nextcloud"];
  # };
})

