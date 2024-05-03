{
  lib,
  user,
  ...
}: {
    # boot.resumeDevice = "/dev/disk/by-label/SWAP";
    boot.kernelParams = [ "mem_sleep_default=deep" ];

    boot.zfs.allowHibernation = true;
    boot.zfs.forceImportRoot = false;

    # disable power button turning off the system
    services.logind.extraConfig = ''
      # don’t shutdown when power button is short-pressed
      HandlePowerKey=lock
      HandleSuspendKey=lock
      HandleHibernateKey=lock
      IdleAction=lock
    '';

    systemd.sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
      #SuspendMode=
      SuspendState=mem standby freeze
      # Configure suspend as hybrid-sleep
      SuspendMode=suspend platform shutdown
      SuspendState=disk
      HibernateMode=platform shutdown
      HibernateState=disk
      HybridSleepMode=suspend platform shutdown
      HybridSleepState=disk
      HibernateDelaySec=60min
    '';

    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      "hybrid-sleep".enable = false;
    };
    services.acpid = {
      enable = true;
      lidEventCommands =
        ''
          /etc/profiles/per-user/${user}/bin/hypr-lock
        '';

      powerEventCommands =
        ''
          /etc/profiles/per-user/${user}/bin/hypr-lock
        '';
    };
}
