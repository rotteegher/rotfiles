{
  config,
  user,
  lib,
  ...
}: let
  cfg = config.custom.hdds;
in {
  services.samba = lib.mkIf cfg.enable {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.0. 192.168.1. 192.168.12. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      # persist = {
      #   path = "/persist/";
      #   browseable = "yes";
      #   "read only" = "no";
      #   "guest ok" = "no";
      #   "create mask" = "0644";
      #   "directory mask" = "0755";
      #   "force user" = "${user}";
      #   "force group" = "users";
      # };
      # wdc-data = lib.mkIf cfg.wdc1tb {
      #   path = "/md/wdc-data/";
      #   browseable = "yes";
      #   "read only" = "no";
      #   "guest ok" = "no";
      #   "create mask" = "0644";
      #   "directory mask" = "0755";
      #   "force user" = "${user}";
      #   "force group" = "users";
      # };
      korobka = lib.mkIf cfg.wdc1tb {
        path = "/md/wdc-data/_KOROBKA";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${user}";
        "force group" = "users";
      };


      stsea-okii = lib.mkIf cfg.stsea3tb {
        path = "/md/stsea-okii/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${user}";
        "force group" = "users";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  custom.persist = {
    root.directories = ["/var/lib/samba"];
  };
}
