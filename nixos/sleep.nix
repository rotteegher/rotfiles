{
  lib,
  ...
}: {
    # boot.resumeDevice = "/dev/disk/by-label/SWAP";
    boot.kernelParams = [ "mem_sleep_default=deep" ];

    boot.zfs.allowHibernation = true;
    boot.zfs.forceImportRoot = false;

    systemd.sleep.extraConfig = ''
      AllowSuspend=yes
      AllowHibernation=yes
      AllowSuspendThenHibernate=yes
      AllowHybridSleep=yes
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
      sleep.enable = true;
      suspend.enable = true;
      hibernate.enable = true;
      "hybrid-sleep".enable = true;
    };
}
