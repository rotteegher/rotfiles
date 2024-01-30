{
  pkgs,
  user,
  config,
  lib,
  ...
}: let
  cfg = config.custom-nixos.virt-manager;
in {
  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    environment.systemPackages = with pkgs; [
      virtiofsd
      qemu
    ];

    users.users.${user}.extraGroups = ["libvirtd"];

    custom-nixos.persist.root.directories = [
      "/var/lib/libvirt"
    ];
  };
}
