{ config, lib, pkgs, ...}:
lib.mkIf config.custom.nginx.enable {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "192.168.1.101" = {
        listen = [
          # { addr = "0.0.0.0"; port = 9999; }
          { addr = "0.0.0.0"; port = 80;}
        ];
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:1111";
          };
        };
      };

      "localhost" = {
        listen = [
          # { addr = "0.0.0.0"; port = 9999; }
          { addr = "0.0.0.0"; port = 80;}
        ];
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8080";
          };
        };
      };

      "192.168.12.1" = {
        listen = [
          # { addr = "0.0.0.0"; port = 9999; }
          { addr = "0.0.0.0"; port = 80; }
        ];
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:1111";
          };
        };
      };

      "nextcloud.farmtasker.au" = {
        listen = [
          # { addr = "0.0.0.0"; port = 9999; }
          { addr = "0.0.0.0"; port = 80; }
        ];
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1";
          };
        };
      };

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
            return = "302 /filebrowser/";
          };
          "/filebrowser/" = {
            extraConfig = ''
              rewrite ^/filebrowser/(.*) /$1 break;
              proxy_pass http://127.0.0.1:3333/;
            '';
          };
          "/static-web-server/" = {
            extraConfig = ''
              rewrite ^/static-web-server/(.*) /$1 break;
              proxy_pass http://127.0.0.1:2222/;
            '';
          };
        };
      };

      "rotteegher.ddns.net" = {
        enableACME = true;
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
            return = "302 /filebrowser/";
          };
          "/filebrowser/" = {
            extraConfig = ''
              rewrite ^/filebrowser/(.*) /$1 break;
              proxy_pass http://127.0.0.1:3333/;
            '';
          };
          "/static-web-server/" = {
            extraConfig = ''
              rewrite ^/static-web-server/(.*) /$1 break;
              proxy_pass http://127.0.0.1:2222/;
            '';
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
