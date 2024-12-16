{ config, lib, pkgs, ...}:
lib.mkIf config.custom.nginx.enable {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "pr.farmtasker.au" = {
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
        listen = [
          # { addr = "0.0.0.0"; port = 9999; }
          { addr = "0.0.0.0"; port = 80; }
        ];
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:1112";
            # return = "403";
          };
        };
      };

      "jellyfin.farmtasker.au" = {
        listen = [
          # { addr = "0.0.0.0"; port = 9999; }
          { addr = "0.0.0.0"; port = 80; }
        ];
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8096";
          };
        };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 9999 80 ];
  networking.firewall.allowedUDPPorts = [ 9999 80 ];
}
