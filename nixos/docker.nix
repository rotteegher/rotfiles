{
  user,
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.custom-nixos.docker.enable || config.custom-nixos.distrobox.enable) {
  environment.systemPackages = lib.mkIf config.custom-nixos.distrobox.enable [ pkgs.distrobox ];

  users.users.${user}.extraGroups = [ "docker" ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    storageDriver = lib.mkIf (config.fileSystems."/".fsType == "zfs") "zfs";
  };

  # store docker images on zroot/cache
  custom-nixos.persist = {
    root = {
      cache = [ "/var/lib/docker" ];
    };
  };
}

