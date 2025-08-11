{ config, lib, pkgs, ...}:
lib.mkIf config.custom.nginx.enable {
  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      map $http_origin $cors_origin {
        default                      "";
        https://janitorai.com        https://janitorai.com;
        https://www.janitorai.com    https://www.janitorai.com;
        # add more allowed origins if needed
      }
    '';
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
        extraConfig = ''
          # real client IP forwarding
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          # upload tuning
          client_max_body_size 0;
          proxy_request_buffering off;
          proxy_http_version 1.1;
        '';
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
        serverName = "rotteegher.ddns.net";
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
          "/api" = {
            proxyPass = "http://127.0.0.1:11434";
            extraConfig = ''
              proxy_hide_header Access-Control-Allow-Origin;

              # neutralize preflight noise to upstream
              proxy_set_header Origin "";
              proxy_set_header Access-Control-Request-Method "";
              proxy_set_header Access-Control-Request-Headers "";

              # *** key line ***
              proxy_set_header Host localhost;

              # optional: don’t leak real client IP to Ollama
              # (not strictly required—Host is the big one)
              proxy_set_header X-Real-IP 127.0.0.1;
              proxy_set_header X-Forwarded-For 127.0.0.1;
              proxy_set_header X-Forwarded-Proto http;

              add_header Access-Control-Allow-Origin * always;
              add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
              add_header Access-Control-Allow-Headers "authorization,content-type" always;
              if ($request_method = OPTIONS) { return 204; }

              proxy_http_version 1.1;
              proxy_read_timeout 1h;
            '';
          };
          "/v1" = {
            proxyPass = "http://127.0.0.1:11434";
            extraConfig = ''
              proxy_hide_header Access-Control-Allow-Origin;

              # neutralize preflight noise to upstream
              proxy_set_header Origin "";
              proxy_set_header Access-Control-Request-Method "";
              proxy_set_header Access-Control-Request-Headers "";

              # *** key line ***
              proxy_set_header Host localhost;

              # optional: don’t leak real client IP to Ollama
              # (not strictly required—Host is the big one)
              proxy_set_header X-Real-IP 127.0.0.1;
              proxy_set_header X-Forwarded-For 127.0.0.1;
              proxy_set_header X-Forwarded-Proto http;

              add_header Access-Control-Allow-Origin * always;
              add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
              add_header Access-Control-Allow-Headers "authorization,content-type" always;
              if ($request_method = OPTIONS) { return 204; }

              proxy_http_version 1.1;
              proxy_read_timeout 1h;
            '';
          };
        };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 9999 80 443 3000 2222 11434 11435 21434 ];
  networking.firewall.allowedUDPPorts = [ 9999 80 443 3000 2222 11434 11435 21434 ];
}
