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
    LC_TIME = "en_AU.UTF-8";
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
        enabled = "ibus";
        ibus.engines = with pkgs.ibus-engines; [ anthy ];
    };
  };

  # KEYMAPS
  console = {
    # font = "ruscii_8x8";
    font = "drdos8x14";
    packages = with pkgs; [ terminus_font ];
    keyMap = "jp106";
    # useXkbConfig = true; # use xkbOptions in tty.

  };
  services.gpm.enable = true;

  services.input-remapper = {
    enableUdevRules = true;
    package = pkgs.input-remapper;
    enable = true;
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
  security = {
    sudo.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # enable sysrq in case for kernel panic
  boot.kernel.sysctl."kernel.sysrq" = 1;

  # enable opengl
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # zram
  zramSwap.enable = true;

  # do not change this value
  system.stateVersion = "23.05";
}
