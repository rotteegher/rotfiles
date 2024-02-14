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
    boot = {
      # booting with zfs
      supportedFilesystems = ["zfs"];
      initrd.supportedFilesystems = ["zfs"];
      kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
      zfs = {
        devNodes = lib.mkDefault "/dev/disk/by-partuuid/";
        enableUnstable = true;
        requestEncryptionCredentials = cfg.encryption;
      };
    };

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
        neededForBoot = !persistCfg.tmpfs && cfg.erase.root;
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
        neededForBoot = !persistCfg.tmpfs && cfg.erase.home;
      };

      "/persist" = {
        device = "zroot/persist";
        fsType = "zfs";
        neededForBoot = true;
      };

      "/persist/cache" = {
        device = "zroot/cache";
        fsType = "zfs";
        neededForBoot = true;
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
    systemd.tmpfiles.rules = [
      "d /persist/home/${user}/Documents 755 ${user} users - "
      "d /persist/home/${user}/Downloads 755 ${user} users - "
      "d /persist/home/${user}/Pictures  755 ${user} users - "
    ];
    # SYNOPSIS - https://www.mankier.com/5/tmpfiles.d
    # Type  Path                                     Mode User Group Age         Argument
    # f     /file/to/create                          mode user group -           content
    # f+    /file/to/create-or-truncate              mode user group -           content
    # w     /file/to/write-to                        -    -    -     -           content
    # w+    /file/to/append-to                       -    -    -     -           content
    # d     /directory/to/create-and-clean-up        mode user group cleanup-age -        # Doesn't cleanup if age is NOT specified
    # D     /directory/to/create-and-remove          mode user group cleanup-age -
    # e     /directory/to/clean-up                   mode user group cleanup-age -
    # v     /subvolume-or-directory/to/create        mode user group cleanup-age -
    # q     /subvolume-or-directory/to/create        mode user group cleanup-age -
    # Q     /subvolume-or-directory/to/create        mode user group cleanup-age -
    # p     /fifo/to/create                          mode user group -           -
    # p+    /fifo/to/[re]create                      mode user group -           -
    # L     /symlink/to/create                       -    -    -     -           symlink/target/path
    # L+    /symlink/to/[re]create                   -    -    -     -           symlink/target/path
    # c     /dev/char-device-to-create               mode user group -           major:minor
    # c+    /dev/char-device-to-[re]create           mode user group -           major:minor
    # b     /dev/block-device-to-create              mode user group -           major:minor
    # b+    /dev/block-device-to-[re]create          mode user group -           major:minor
    # C     /target/to/create                        -    -    -     cleanup-age /source/to/copy
    # C+    /target/to/create                        -    -    -     cleanup-age /source/to/copy
    # x     /path-or-glob/to/ignore/recursively      -    -    -     cleanup-age -
    # X     /path-or-glob/to/ignore                  -    -    -     cleanup-age -
    # r     /path-or-glob/to/remove                  -    -    -     -           -
    # R     /path-or-glob/to/remove/recursively      -    -    -     -           -
    # z     /path-or-glob/to/adjust/mode             mode user group -           -
    # Z     /path-or-glob/to/adjust/mode/recursively mode user group -           -
    # t     /path-or-glob/to/set/xattrs              -    -    -     -           xattrs
    # T     /path-or-glob/to/set/xattrs/recursively  -    -    -     -           xattrs
    # h     /path-or-glob/to/set/attrs               -    -    -     -           file attrs
    # H     /path-or-glob/to/set/attrs/recursively   -    -    -     -           file attrs
    # a     /path-or-glob/to/set/acls                -    -    -     -           POSIX ACLs
    # a+    /path-or-glob/to/append/acls             -    -    -     -           POSIX ACLs
    # A     /path-or-glob/to/set/acls/recursively    -    -    -     -           POSIX ACLs
    # A+    /path-or-glob/to/append/acls/recursively -    -    -     -           POSIX ACLs
  };
}
