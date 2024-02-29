{
  lib,
  config,
  user,
  ...
}: let
  cfg = config.custom-nixos.hdds;
  wdc-blue-mountpoint = "/md/wdc-data";
  wdc-blue-dataset = "wdc-blue/data";
  stsea-mountpoint = "/md/stsea-okii";
  stsea-dataset = "stsea-barra/okii";
in {
  config = lib.mkIf cfg.enable {
    # non os zfs disks
    boot.zfs.extraPools = ["wdc-blue" "stsea-barra"];
    # lib.optional cfg.wdc1tb "wdc-blue"
    # ++ (lib.optional cfg.stsea3tb "stsea-barra");

    services.sanoid = lib.mkIf config.custom-nixos.zfs.snapshots {
      enable = true;

      datasets = {
        ${wdc-blue-dataset} = lib.mkIf cfg.wdc1tb {
          hourly = 3;
          daily = 10;
          weekly = 2;
          monthly = 0;
        };
        ${stsea-dataset} = lib.mkIf cfg.stsea3tb {
          hourly = 3;
          daily = 10;
          weekly = 2;
          monthly = 0;
        };
      };
    };

    # add bookmarks for gtk
    hm = {...} @ hmCfg: {
      gtk.gtk3.bookmarks = lib.mkIf cfg.wdc1tb [
        "file://${wdc-blue-mountpoint}/_SMALL/_ANIME/_CURRENT/ _CURRENT"
        # "file://${wdc-blue-mountpoint}/TV/Current TV Current"
        "file://${wdc-blue-mountpoint}/_SMALL/_ANIME/ _ANIME"
        # "file://${wdc-blue-mountpoint}/TV TV"
        "file://${wdc-blue-mountpoint}/_SMALL/ _SMALL"
        "file://${wdc-blue-mountpoint}/_SMALL/_FILM/ _FILM"
        "file://${wdc-blue-mountpoint}/_SMALL/_IMAGE/ _IMAGE"
        "file://${wdc-blue-mountpoint}/_MAIN/ _MAIN"
        "file://${wdc-blue-mountpoint}/_MAIN/_NT_STUDIO _NT_STUDIO"
        "file://${wdc-blue-mountpoint}/papers papers"
      ];

      # create symlinks for locations with ~
      home.file = let
        mkOutOfStoreSymlink = hmCfg.config.lib.file.mkOutOfStoreSymlink;
      in {
        Downloads.source = lib.mkIf cfg.wdc1tb (mkOutOfStoreSymlink "${wdc-blue-mountpoint}/Downloads");
        # Videos.source = lib.mkIf cfg.wdc1tb (mkOutOfStoreSymlink "${wdc-blue-mountpoint}/Videos"); #TODO
      };
    };

    # symlinks from hdds
    # dest src
    systemd.tmpfiles.rules = lib.optionals (cfg.wdc1tb && cfg.stsea3tb) [
      "L+ ${wdc-blue-mountpoint}/Wallpapers            - - - - /home/${user}/Pictures/Wallpapers"
      "L+ ${wdc-blue-mountpoint}/pr/rustpr             - - - - /home/${user}/pr/rustpr/ln/"
      # "L+ ${wdc-blue-mountpoint}/_SMALL                - - - - /home/${user}/_SMALL"
      # "L+ ${wdc-blue-mountpoint}/_MAIN                - - - - /home/${user}/_MAIN"
      # "L+ ${stsea-mountpoint}/Movies           - - - - ${wdc-blue-mountpoint}/Movies"
      # "L+ ${stsea-mountpoint}/TV               - - - - ${wdc-blue-mountpoint}/TV"
    ];

    # dual boot windows
    boot.loader.grub = {
      extraEntries = lib.concatStringsSep "\n" (lib.optional cfg.windows ''
        menuentry "Windows 10" {
          insmod part_gpt
          insmod ntfs
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root 14A1-3DF5
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '');
    };

    fileSystems = {
      "/windows" = {
        device = "/dev/disk/by-label/WINDOWS";
        fsType = "ntfs";
        neededForBoot = false;
      };

      "/md/wdc-data" = {
        device = "wdc-blue/data";
        fsType = "zfs";
        neededForBoot = false;
      };
      "/md/stsea-okii" = {
        device = "stsea-barra/okii";
        fsType = "zfs";
        neededForBoot = false;
      };
    };
  };
}
