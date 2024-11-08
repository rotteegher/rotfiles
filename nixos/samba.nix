{
  config,
  user,
  pkgs,
  lib,
  ...
}: let
  cfg = config.custom.samba;
in {
  services.samba = lib.mkIf cfg.enable {
    enable = true;
    openFirewall = true;
    nmbd.enable = true;
    package = pkgs.samba4Full;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        # "use sendfile" = "yes";
        # "max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "0.0.0.0/0";
        "hosts deny" = "";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        # "msdfs root" = "no";
      };
      "korobka" = lib.mkIf config.custom.hdds.wdc1tb {
        "path" = "/md/wdc-data/_KOROBKA";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${user}";
        "force group" = "users";
      };

      # "stsea-okii" = lib.mkIf config.custom.hdds.stsea3tb {
      #   "path" = "/md/stsea-okii/";
      #   "browseable" = "yes";
      #   "read only" = "no";
      #   "guest ok" = "no";
      #   "create mask" = "0644";
      #   "directory mask" = "0755";
      #   "force user" = "${user}";
      #   "force group" = "users";
      # };
    };
  };

  services.samba-wsdd = lib.mkIf cfg.enable {
    enable = true;
    openFirewall = true;
    discovery = true;
  };

  networking.firewall.allowedTCPPorts = [ 445 ];
  networking.firewall.allowedUDPPorts = [ 445 ];


  custom.persist = lib.mkIf cfg.enable {
    root.directories = ["/var/lib/samba"];
  };
}
