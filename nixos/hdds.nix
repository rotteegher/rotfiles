{ lib, config, user, ... }:
let
  cfg = config.custom.hdds;
  wdc-blue-mountpoint = "/md/wdc-data";
  wdc-blue-dataset = "wdc-blue/data";
in {
  config = lib.mkIf cfg.enable {
    # non os zfs disks
    boot.zfs.extraPools = [
      (lib.optionalString cfg.wdc1tb "wdc-blue")
    ];
    boot.kernelModules = [ "brd" ];
    boot.extraModprobeConfig = ''
      options brd rd_nr=1 rd_size=41943040
      options zfs zfs_arc_max=51539607552
    '';

    services.sanoid = lib.mkIf config.custom.zfs.snapshots {
      enable = true;

      datasets = {
        ${wdc-blue-dataset} = lib.mkIf cfg.wdc1tb {
          hourly = 24;
          daily = 31;
          weekly = 7;
          monthly = 1;
        };
      };
    };

    custom.shell.packages = {
      zfs-destroy-dataset-snapshots = ''
        for i in $(zfs list -t snapshot "$1" -H | awk '{print $1}' | grep autosnap); do 
            echo WILL DESTROY: "$i"
        done

        # Ask for confirmation
        read -r -p "Are you sure you want to destroy these snapshots? (y/n): " confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            for i in $(zfs list -t snapshot "$1" -H | awk '{print $1}' | grep autosnap); do 
                sudo zfs destroy "$i"
            done
        else
            echo "Operation cancelled."
        fi
      '';
    };

    # add bookmarks for gtk
    hm = { ... }@hmCfg: {
      gtk.gtk3.bookmarks = lib.optionals cfg.wdc1tb [
        "file://${wdc-blue-mountpoint}/_SMALL/_ANIME/ _ANIME"
        "file://${wdc-blue-mountpoint}/_SMALL/ _SMALL"
        "file://${wdc-blue-mountpoint}/_SMALL/_FILM/ _FILM"
        "file://${wdc-blue-mountpoint}/_SMALL/_IMAGE/ _IMAGE"
        "file://${wdc-blue-mountpoint}/_MAIN/ _MAIN"
        "file://${wdc-blue-mountpoint}/_MAIN/_NT_STUDIO _NT_STUDIO"
        "file://${wdc-blue-mountpoint}/Documents/papers papers"
        "file://${wdc-blue-mountpoint}/_FARMTASKER _FARMTASKER"
        "file://${wdc-blue-mountpoint}/ wdc-blue/data"
      ];
      # create symlinks for locations with ~
      home.file =
        let mkOutOfStoreSymlink = hmCfg.config.lib.file.mkOutOfStoreSymlink;
        in {
          "Downloads".source = lib.mkIf cfg.wdc1tb
            (mkOutOfStoreSymlink "${wdc-blue-mountpoint}/Downloads");
          "Videos".source = lib.mkIf cfg.wdc1tb
            (mkOutOfStoreSymlink "${wdc-blue-mountpoint}/Videos");
          "Documents".source = lib.mkIf cfg.wdc1tb
            (mkOutOfStoreSymlink "${wdc-blue-mountpoint}/Documents");
          # causes error for some reason vvvvvvvvvvvvvv
          # "Desktop".source = lib.mkIf cfg.wdc1tb (mkOutOfStoreSymlink "${wdc-blue-mountpoint}/Desktop");
        };
    };

    # symlinks from hdds
    # dest src
    systemd.tmpfiles.rules = lib.optionals cfg.enable [
      "L+ ${wdc-blue-mountpoint}/Wallpapers            - - - - /home/${user}/Pictures/Wallpapers"
      "L+ ${wdc-blue-mountpoint}/pr/rustpr             - - - - /home/${user}/pr/rustpr/ln/"
      "L+ /home/${user}/_MAIN                          - - - - ${wdc-blue-mountpoint}/_MAIN"
      "L+ /home/${user}/_SMALL                         - - - - ${wdc-blue-mountpoint}/_SMALL"
      "L+ /home/${user}/_FARMTASKER                       - - - - ${wdc-blue-mountpoint}/_FARMTASKER"
      "L+ /home/${user}/_SMALL/_MUSIC                  - - - - ${wdc-blue-mountpoint}/_MUSIC"
      "L+ /home/${user}/_SMALL/_FILM                   - - - - ${wdc-blue-mountpoint}/_FILM"
      "L+ /home/${user}/_SMALL/_ANIME                  - - - - ${wdc-blue-mountpoint}/_ANIME"
    ];

    # dual boot windows
    boot.loader.grub = {
      # extraEntries = lib.concatStringsSep "\n" (
      #   lib.optional cfg.windows ''
      #     menuentry "Windows 10" {
      #       insmod part_gpt
      #       insmod ntfs
      #       insmod search_fs_uuid
      #       insmod chain
      #       search --fs-uuid --set=root 703A-A953
      #       chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      #     }
      #   ''
      # );
    };

    fileSystems = lib.mkIf cfg.enable {
      # "/md/windows" = lib.mkIf cfg.windows {
      #   device = "/dev/disk/by-label/WINDOWS";
      #   fsType = "ntfs";
      #   neededForBoot = false;
      # };
      "/md/wdc-data" = lib.mkIf cfg.wdc1tb {
        device = "wdc-blue/data";
        fsType = "zfs";
        neededForBoot = false;
      };
    };
  };
}
