{
  config,
  user,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.static-web-server;
  domain-name = "rotteegher.ddns.net";
  path-to-serve = "/md/wdc-data/_SMALL/_ONLINE_TANK";
in lib.mkMerge [
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "noisetide@proton.me";
  };

  # Now we need to open port 80 for the ACME challenge and port 443 for SWS itself
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Configure SWS to use the generated TLS certs
  services.static-web-server = lib.mkIf cfg.enable {
    enable = true;
    root = path-to-serve;
    listen = cfg.listen;
    configuration = {
      general = { 
        directory-listing = true;
        directory-listing-order = 1;
        directory-listing-format = "html";
        directory-listing-download = [];

        security-headers = true;
        log-level = "trace";
        #### Log request Remote Address if available
        log-remote-address = true;
        # #### Log real IP from X-Forwarded-For header if available
        log-forwarded-for = true;

        redirect-trailing-slash = true;
        health = false;

        cache-control-headers = true;
        compression = true;
        compression-level = "default";
        compression-static = true;

        maintenance-mode = false;
      };
    };
  };

    # Ensure FileBrowser is available
  environment.systemPackages = [ pkgs.filebrowser ];

  # Define the systemd service for FileBrowser
  systemd.services.filebrowser = {
    description = "FileBrowser Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.filebrowser}/bin/filebrowser -d /var/lib/filebrowser/filebrowser.db --username ${user} --password $SERVER_AUTH --baseurl /filebrowser -r ${path-to-serve} -p 3333";
      WorkingDirectory = path-to-serve;
      StateDirectory = "filebrowser";
      Restart = "on-failure";
      RestartSec = 5;
      User = user;
      Group = "users";
    };
  };


  # Now we need to override some things in the systemd unit files to allow access to those TLS certs, starting with creating a new Linux group:
  users.groups.www-data = {};
  # This strategy can be useful to override other advanced features as-needed
  systemd.services.static-web-server.serviceConfig.SupplementaryGroups = pkgs.lib.mkForce [ "" "www-data" ];
  # Note that "/some/path" should match your "root" option
  systemd.services.static-web-server.serviceConfig.BindReadOnlyPaths = pkgs.lib.mkForce [
    # "/some/path"
    "/var/lib/acme/${domain-name}"
  ];

  custom.persist = {
    root.directories = ["/var/lib/acme" "/var/lib/filebrowser"];
  };
}
(lib.mkIf config.custom.sops.enable {
      sops.secrets.sws.owner = user;
      sops.secrets.swsb.owner = user;

      systemd.services.static-web-server = {
        serviceConfig = {
          EnvironmentFile = config.sops.secrets.sws.path;
        };
      };

      systemd.services.filebrowser = {
        serviceConfig = {
          EnvironmentFile = config.sops.secrets.swsb.path;
        };
      };

  })
]
