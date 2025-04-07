{
  user,
  pkgs,
  lib,
  config,
  isNixOS,
  ...
}:
{
  imports = [
    ./hyprland
    ./programs
    ./shell
  ];

  # setup fonts for other distros, run "fc-cache -f" to refresh fonts
  fonts.fontconfig = {
    enable = true;
  };

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    # do not change this value
    stateVersion = "23.05";

    sessionVariables = {
      __IS_NIXOS = if isNixOS then "1" else "0";
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    packages =
      with pkgs;
      [
        curl
        gzip
        wget
        killall
        # rar # includes unrar
        zip # not includes unzip
        rsync
        sendme
        unzip
        p7zip
        lzip
        ripgrep
        libreoffice
        onlyoffice-bin
        zathura
        mupdf
        digikam
        trash-cli
        xdg-utils
        zenity

        # mcomix
        yacreader
        musescore

        # misc utilities for dotfiles written in rust
        custom.dotfiles-utils
      ]
      ++ (lib.optional config.custom.helix.enable helix)
      # home-manager executable only on non-nixos
      ++ (lib.optional isNixOS home-manager)
      # handle fonts
      ++ (lib.optionals (!isNixOS) config.custom.fonts.packages)
      # add custom user created shell packages
      ++ (lib.attrValues config.custom.shell.finalPackages);
  };

  # add custom user created shell packages to pkgs.custom.shell
  nixpkgs.overlays = lib.mkIf (!isNixOS) [
    (_: prev: {
      custom = prev.custom // {
        shell = config.custom.shell.finalPackages;
      };
    })
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # stop bothering me
  xdg = {
    enable = true;
    userDirs.enable = true;
    mimeApps.enable = true;
  };

  custom.persist = {
    home.directories = [ "Pictures" ];
    home.files = [ ".config/digikamrc" ".config/digikam_systemrc" ];
  };
}
