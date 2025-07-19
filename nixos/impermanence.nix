{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.custom-nixos.persist;
  hmPersistCfg = config.hm.custom.persist;
in
{
  boot = {
    # clear /tmp on boot
    tmp.cleanOnBoot = true;

    # root / home filesystem is destroyed and rebuilt on every boot:
    # https://grahamc.com/blog/erase-your-darlings
    initrd.postDeviceCommands = lib.mkAfter ''
      ${lib.optionalString (!cfg.tmpfs && cfg.erase.root) "zfs rollback -r zroot/root@blank"}
      ${lib.optionalString (!cfg.tmpfs && cfg.erase.home) "zfs rollback -r zroot/home@blank"}
    '';
  };

  # replace root and / or home filesystems with tmpfs
  # neededForBoot is required, so there won't be permission errors creating directories or symlinks
  # https://github.com/nix-community/impermanence/issues/149#issuecomment-1806604102
  fileSystems = {
    "/" = lib.mkIf (cfg.tmpfs && cfg.erase.root) (
      lib.mkForce {
        device = "tmpfs";
        fsType = "tmpfs";
        neededForBoot = true;
        options = [
          "defaults"
          "size=16G"
          "mode=755"
        ];
      }
    );
    # ${homeDir} causes infinite recursion
    "/home/${user}" = lib.mkIf (cfg.tmpfs && cfg.erase.home) (
      lib.mkForce {
        device = "tmpfs";
        fsType = "tmpfs";
        neededForBoot = true;
        options = [
          "defaults"
          "size=16G"
          "mode=777"
        ];
      }
    );
  };

  # shut sudo up
  security.sudo.extraConfig = "Defaults lecture=never";

  # setup persistence
  environment.persistence = {
    "/persist" = {
      hideMounts = true;
      files = [ "/etc/machine-id" ] ++ cfg.root.files;
      directories = [
        "/var/log" # systemd journal is stored in /var/log/journal
      ] ++ cfg.root.directories;

      users.${user} = {
        files = cfg.home.files ++ hmPersistCfg.home.files;
        directories = [
          "pr"
          ".cache/dconf"
          ".config/dconf"
          ".local/state/nix/profiles"
        ]
          ++ lib.optionals config.programs.steam.enable [ ".steam"]
          ++ cfg.home.directories ++ hmPersistCfg.home.directories;
      };
    };

    "/persist/cache" = {
      hideMounts = true;
      directories = cfg.root.cache;

      users.${user} = {
        directories = hmPersistCfg.home.cache;
      };
    };
  };
}
