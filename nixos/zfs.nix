{
  config,
  lib,
  user,
  pkgs,
  ...
}: let
  cfg = config.custom-nixos.zfs;
  persistCfg = config.custom-nixos.persist;
in {
  config = lib.mkIf cfg.enable {
    # booting with zfs
    boot.supportedFilesystems = ["zfs"];
    boot.initrd.supportedFilesystems = ["zfs"];
    boot.zfs.devNodes = lib.mkDefault "/dev/disk/by-partuuid/";
    # boot.zfs.enableUnstable = true;
    boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    # boot.zfs.requestEncryption = cfg.encryption;

    services.zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    swapDevices = [
      {
        device = "/dev/disk/by-label/SWAP";
      }
    ];

    fileSystems = let
      homeMountPoint =
        if persistCfg.erase.home
        then "/home/${user}"
        else "/home";
    in {
      # boot partition
      "/boot" = {
        device = "/dev/disk/by-id/nvme-eui.32333033363336334ce0001835313730-part1";
        fsType = "vfat";
      };
      # zfs datasets
      "/" = {
        device = "zroot/root";
        fsType = "zfs";
      };

      "/nix" = {
        device = "zroot/nix";
        fsType = "zfs";
      };

      "/tmp" = {
        device = "zroot/tmp";
        fsType = "zfs";
      };

      "${homeMountPoint}" = {
        device = "zroot/home";
        fsType = "zfs";
      };

      "/persist" = {
        device = "zroot/persist";
        fsType = "zfs";
        neededForBoot = true;
      };

      "/persist/cache" = {
        device = "zroot/cache";
        fsType = "zfs";
      };
      "/backup" = {
        device = "zroot/backup";
        fsType = "zfs";
      };
    };
    services.sanoid = lib.mkIf cfg.snapshots {
      enable = true;

      datasets = {
        "zroot/home" = lib.mkIf (!persistCfg.erase.home) {
          hourly = 50;
          daily = 20;
          weekly = 6;
          monthly = 3;
        };

        "zroot/persist" = {
          hourly = 50;
          daily = 20;
          weekly = 6;
          monthly = 3;
        };
      };
    };
  };
}
