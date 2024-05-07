{
  user,
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.custom.docker.enable || config.custom.distrobox.enable) {
  environment.systemPackages = lib.mkIf config.custom.distrobox.enable [pkgs.distrobox];

  users.users.${user}.extraGroups = ["docker"];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    storageDriver = lib.mkIf (config.fileSystems."/".fsType == "zfs") "zfs";
  };

  # store docker images on zroot/cache
  custom.persist = {
    root = {
      cache = ["/var/lib/docker"];
    };
  };
}
