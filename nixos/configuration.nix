{
  pkgs,
  user,
  host,
  ...
}: {
  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      device = "nodev";
      zfsSupport = true;
      efiSupport = true;
      useOSProber = false;
      default = "saved";
    };
  };

  networking.hostName = "${host}";
  networking.nameservers = ["8.8.8.8" "8.8.8.8"];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set Your time zone.
  time.timeZone = "Australia/Hobart";

  # Locale Extra
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    # week starts on a Monday, for fuck's sake
    LC_TIME = "uk_UA.UTF-8";
  };


  # Configure keymap in X11
  services.xserver = {
    layout = "jp";
    xkbVariant = "";
    xkbOptions = "japan:hztg_escape";
    # bye bye xterm
    excludePackages = [pkgs.xterm];
  };

  # Define a user account. Don't forget to set a pasword with 'passwd'.
  users.users.${user} = {...}: {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  # Reboot/poweroff for unprivileged users
  # Grants permissions to reboot/poweroff machine to users in the users group. 
  security = {
    sudo.enable = true;
    # i can't type xD
    sudo.extraConfig = "Defaults passwd_tries=10";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Cuda support
  nixpkgs.config.cudaSupport = true;

  # enable sysrq in case for kernel panic
  boot.kernel.sysctl."kernel.sysrq" = 1;

  # enable opengl
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # zram
  zramSwap.enable = true;

  # do not change this value
  system.stateVersion = "23.05";
}
