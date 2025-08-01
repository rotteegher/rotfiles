{
  config,
  lib,
  user,
  pkgs,
  ...
}: let
  cfg = config.custom.vm;
in {
  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;

    users.groups.libvirtd.members = ["${user}"];
    users.users.${user}.extraGroups = [ "libvirtd" ];

    virtualisation.libvirtd.enable = true;

    virtualisation.spiceUSBRedirection.enable = true;

    custom.persist = {
      root.directories = ["/var/lib/libvirt"];
      root.cache = [
        "/home/${user}/.cache/libvirt"
        "/home/${user}/.cache/virt-manager"
      ];
    };    
  };
}

