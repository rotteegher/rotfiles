{
  host,
  pkgs,
  config,
  ...
}:
{
  # Bootloader.
  # boot.loader.systemd-boot.enable = false;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      devices = [ "nodev" ];
      zfsSupport = true;
      efiSupport = true;
      useOSProber = false;
      default = "saved";
      theme = pkgs.custom.distro-grub-themes-nixos;
      gfxmodeBios = "1920x1080";
      gfxmodeEfi = "1920x1080";
    };
  };

  fonts.packages = config.hm.custom.fonts.packages;

  powerManagement.enable = true;

  systemd.enableEmergencyMode = false;

  networking.hostName = "${host}";

  networking.hosts = {
    "127.0.0.1" = [ "local.farmtasker.au" "rotteegher.ddns.net" "116.250.178.114" ];
    "localhost" = [ "local.farmtasker.au" "rotteegher.ddns.net" "116.250.178.114" "127.0.0.1" ];
    "desktop" = [ "local.farmtasker.au" "rotteegher.ddns.net" "116.250.178.114" ];
    "omen" = ["192.168.1.104" "192.168.1.105" "192.168.12.22"];
    "192.168.12.22" = ["omen"];
    "192.168.1.104" = ["omen"];
    "192.168.1.105" = ["omen"];
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set Your time zone.
  time.timeZone = "Australia/Hobart";

  # Locale Extra
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      # Still can't remember the names of the months in Ukranian, for fuck's sake
      LC_TIME = "uk_UA.UTF-8";
    };
  };

  # Configure X11
  services.xserver = {
    # bye bye xterm
    excludePackages = [ pkgs.xterm ];
  };

  # Reboot/poweroff for unprivileged users
  # Grants permissions to reboot/poweroff machine to users in the users group.
  security = {
    sudo.enable = true;
    # i can't type xD
    sudo.extraConfig = "Defaults passwd_tries=10";
  };

  # enable sysrq in case for kernel panic
  # boot.kernel.sysctl."kernel.sysrq" = 1;

  # enable opengl
  hardware.graphics = {
    enable = true;
  };

  # zram
  zramSwap.enable = true;

  # do not change this value
  system.stateVersion = "23.05";
}
