{
  config,
  user,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.static-web-server;
  domain-name = "rotteegher.ddns.net";
in {
  security.acme = {
    acceptTerms = true;
    defaults.email = "noisetide@proton.me";
    # certs.${domain-name} = {
    #   reloadServices = [ "static-web-server" ];
    #   webroot = null;  # <-- manually disable it to avoid conflicting methods
    #   listenHTTP = ":80";
    #   group = "www-data";
    #   # EC is not supported by SWS versions before 2.16.1
    #   keyType = "rsa4096";
    # };
  };

  # Now we need to open port 80 for the ACME challenge and port 443 for SWS itself
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Configure SWS to use the generated TLS certs
  services.static-web-server = lib.mkIf cfg.enable {
    enable = true;
    root = "/md/wdc-data/_SMALL/_ONLINE_TANK";
    listen = cfg.listen;
    configuration = {
      general = { 
        directory-listing = true;
        log-level = "trace";
        # http2 = true;
        # Edit the domain name in the file to match your real domain name as configured in the ACME settings
        # http2-tls-cert = "/var/lib/acme/${domain-name}/fullchain.pem";
        # http2-tls-key = "/var/lib/acme/${domain-name}/key.pem";
        # Info here: https://static-web-server.net/features/security-headers/
        # This option is only needed for versions prior to 2.18.0, after which it defaults to true
        security-headers = true;
      };
    };
  };

  # Now we need to override some things in the systemd unit files to allow access to those TLS certs, starting with creating a new Linux group:
  # users.groups.www-data = {};
  # This strategy can be useful to override other advanced features as-needed
  # systemd.services.static-web-server.serviceConfig.SupplementaryGroups = pkgs.lib.mkForce [ "" "www-data" ];
  # Note that "/some/path" should match your "root" option
  # systemd.services.static-web-server.serviceConfig.BindReadOnlyPaths = pkgs.lib.mkForce [
  #   # "/some/path"
  #   "/var/lib/acme/${domain-name}"
  # ];

  custom.persist = {
    root.directories = ["/var/lib/acme"];
  };
}
