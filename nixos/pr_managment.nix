{pkgs, user, config, lib, ...}:
let
dataDir = "/srv/mattermost";
in
lib.mkMerge [

(lib.mkIf config.custom.pr_managment.enable {
  # services.mattermost = {
  #   enable = true;
  #   group = "wheel";
  #   statePath = dataDir;
  #   mutableConfig = true;
  #   listenAddress = "0.0.0.0:1111";
  #   siteUrl = "http://pr.farmtasker.au";
  #   siteName = "Farmtasker Project Managment";
  #   preferNixConfig = true;
  # };

  # networking.firewall.allowedTCPPorts = [ 1111 ];
  # custom.persist = {
  #   root.directories = [
  #     dataDir
  #   ];
  # };
})
(lib.mkIf (config.custom.sops.enable && config.custom.pr_managment.enable) {
  # sops.secrets.nextcloud_adminpass.owner = "nextcloud";
  # sops.secrets.nextcloud_adminpass.group = "nextcloud";

  # services.nextcloud = {
  #   enable = true;
  #   package = pkgs.nextcloud30;
  #   home = "/persist/var/lib/nextcloud";
  #   hostName = "127.0.0.1";
  #   config = {
  #     adminuser = "admin";
  #     dbname = "nextcloud";
  #     dbtype = "sqlite";
  #     adminpassFile = config.sops.secrets.nextcloud_adminpass.path;
  #   };
  # };
  # users.users.nextcloud.extraGroups = [ "users" "root" "wheel" ];
  # users.users.${user}.extraGroups = [ "nextcloud" ];

  networking.firewall.allowedTCPPorts = [ 80 ];
  networking.firewall.allowedUDPPorts = [ 80 ];

  custom.persist = {
    # root.directories = ["/var/lib/nextcloud/data"];
  };
})
]
