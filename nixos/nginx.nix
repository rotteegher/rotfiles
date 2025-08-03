{ config, lib, pkgs, ...}:
lib.mkIf config.custom.nginx.enable {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "192.168.1.101" = {
        enableACME = true;
        forceSSL = true;
          sslCertificate = "/var/lib/acme/192.168.1.101/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/192.168.1.101/key.pem";
          sslTrustedCertificate = "/var/lib/acme/192.168.1.101/chain.pem";
        listen = [
          # { addr = "0.0.0.0"; port = 9999; }
          { addr = "0.0.0.0"; port = 443; ssl = true;}
          { addr = "0.0.0.0"; port = 80;}
        ];
        locations = {
          "/" = {
            proxyPass = "https://127.0.0.1:3210";
          };
        };
      };

      "localhost" = {
        enableACME = true;
        forceSSL = true;
          sslCertificate = "/var/lib/acme/localhost/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/localhost/key.pem";
          sslTrustedCertificate = "/var/lib/acme/localhost/chain.pem";
        listen = [
          # { addr = "0.0.0.0"; port = 9999; }
          { addr = "0.0.0.0"; port = 443; ssl = true;}
          { addr = "0.0.0.0"; port = 80;}
        ];
        locations = {
          "/" = {
            proxyPass = "https://127.0.0.1:3210";
          };
        };
      };

      # "nextcloud.farmtasker.au" = {
      #   listen = [
      #     # { addr = "0.0.0.0"; port = 9999; }
      #     { addr = "0.0.0.0"; port = 80; }
      #   ];
      #   locations = {
      #     "/" = {
      #       proxyPass = "http://127.0.0.1";
      #     };
      #   };
      # };

      "local.farmtasker.au" = {
        enableACME = true;
        forceSSL = true;
          sslCertificate = "/var/lib/acme/local.farmtasker.au/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/local.farmtasker.au/key.pem";
          sslTrustedCertificate = "/var/lib/acme/local.farmtasker.au/chain.pem";
        listen = [
          { addr = "0.0.0.0"; port = 443; ssl = true;}
          { addr = "0.0.0.0"; port = 80;}
        ];
        locations = {
          "/" = {
            proxyPass = "https://127.0.0.1:3210";
          };
        };
      };

      "rotteegher.ddns.net" = {
        enableACME = true;
        extraConfig = ''
          proxy_set_header Host             $host;
          proxy_set_header X-Real-IP        $remote_addr;
          proxy_set_header X-Forwarded-For  $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_http_version 1.1;
        '';
        forceSSL = true;
          sslCertificate = "/var/lib/acme/rotteegher.ddns.net/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/rotteegher.ddns.net/key.pem";
          sslTrustedCertificate = "/var/lib/acme/rotteegher.ddns.net/chain.pem";
        listen = [
          { addr = "0.0.0.0"; port = 443; ssl = true;}
          { addr = "0.0.0.0"; port = 80;}
        ];
        locations = {
          "/" = {
            proxyPass = "https://127.0.0.1:3210";
          };
        };
      };

      # "jellyfin.farmtasker.au" = {
      #   listen = [
      #     # { addr = "0.0.0.0"; port = 9999; }
      #     # { addr = "0.0.0.0"; port = 80; }
      #   ];
      #   locations = {
      #     "/" = {
      #       proxyPass = "http://127.0.0.1:8096";
      #     };
      #   };
      # };
    };
  };
  networking.firewall.allowedTCPPorts = [ 9999 80 443 3000 2222 ];
  networking.firewall.allowedUDPPorts = [ 9999 80 443 3000 2222 ];
}
