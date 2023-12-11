  {
    lib,
    config,
    ...
  }: let
    cfg = config.rot-nixos.hdds;
    wdc-blue-mountpoint = "/md/wdc-data";
    wdc-blue-dataset = "wdc-blue/data";
    stsea-mountpoint = "/md/stsea-okii";
    stsea-dataset = "stsea-barra/okii";
  in {
    config = lib.mkIf cfg.enable {
    # non os zfs disks
    boot.zfs.extraPools = [ "wdc-blue" "stsea-barra" ];
      # lib.optional cfg.wdc1tb "wdc-blue"
      # ++ (lib.optional cfg.stsea3tb "stsea-barra");

    services.sanoid = lib.mkIf config.rot-nixos.zfs.snapshots {
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

    # symlinks from hdds
    # dest src
    # systemd.tmpfiles.rules = lib.optionals (cfg.wdc1tb && cfg.stsea3tb) [
    #   "L+ ${stsea-mountpoint}/Anime            - - - - ${wdc-blue-mountpoint}/Anime"
    #   "L+ ${stsea-mountpoint}/Movies           - - - - ${wdc-blue-mountpoint}/Movies"
    #   "L+ ${stsea-mountpoint}/TV               - - - - ${wdc-blue-mountpoint}/TV"
    # ];


    # dual boot windows
    boot.loader.grub = {
      extraEntries = lib.concatStringsSep "\n" ((lib.optional cfg.windows ''
          menuentry "Windows 10" {
            insmod part_gpt
            insmod ntfs
            insmod search_fs_uuid
            insmod chain
            search --fs-uuid --set=root 14A1-3DF5
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
      ''));
    };


    fileSystems = {
      "/windows" = 
        { device = "/dev/disk/by-label/WINDOWS";
          fsType = "ntfs";
          neededForBoot = false;
        };

      "/md/wdc-blue" =
        { device = "wdc-blue/data";
          fsType = "zfs";
          neededForBoot = false;
        };
      "/md/stsea-barra" =
        { device = "stsea-barra/okii";
          fsType = "zfs";
          neededForBoot = false;
        };
    };
  };
}
