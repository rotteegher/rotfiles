{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.custom.persist;
  hmPersistCfg = config.hm.custom.persist;
in
{
  # NOTE: see zfs.nix for filesystem declarations, filesystem creation is handled via install.sh

  boot = {
    # clear /tmp on boot
    tmp.cleanOnBoot = true;

    # root / home filesystem is destroyed and rebuilt on every boot:
    # https://grahamc.com/blog/erase-your-darlings
    initrd.postDeviceCommands = lib.mkAfter (
      lib.optionalString (!cfg.tmpfs) "zfs rollback -r zroot/root@blank"
    );
  };

  # replace root filesystem with tmpfs
  # neededForBoot is required, so there won't be permission errors creating directories or symlinks
  # https://github.com/nix-community/impermanence/issues/149#issuecomment-1806604102
  fileSystems = {
    "/" = lib.mkIf cfg.tmpfs (
      lib.mkForce {
        device = "tmpfs";
        fsType = "tmpfs";
        neededForBoot = true;
        options = [
          "defaults"
          "size=1G"
          "mode=755"
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
        "/var/lib/nixos" # for persisting user uids and gids
      ] ++ cfg.root.directories;

      users.${user} = {
        files = cfg.home.files ++ hmPersistCfg.home.files;
        directories = [
          "pr"
          ".cache/dconf"
          ".config/dconf"
        ] ++ cfg.home.directories ++ hmPersistCfg.home.directories;
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
