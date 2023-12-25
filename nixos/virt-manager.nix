{
  pkgs,
  user,
  config,
  lib,
  ...
}: let
  cfg = config.rot-nixos.virt-manager;
in {
  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    environment.systemPackages = with pkgs; [
      virtiofsd
      qemu
    ];

    users.users.${user}.extraGroups = ["libvirtd"];

    rot-nixos.persist.root.directories = [
      "/var/lib/libvirt"
    ];
  };
}
