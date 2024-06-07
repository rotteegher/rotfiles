{
  pkgs,
  lib,
  isNixOS,
  ...
}:
{
  custom = {
    kbLayout = "jp";
    wifi.enable = true;
    displays = [
      {
        name = "HDMI-A-2"; # ====== 0 horizontal
        hyprland = "1920x1080@60,0x0,1,transform,0"; # |||||| 1 vertical
        workspaces = [
          1
          2
          3
          4
          5
          6
          7
          8
          9
          10
        ];
      }
    ];
    hyprland = {
      modkey = "SUPER"; # could be "ALT"
      autostart = false;
      lock = false;
    };
    waybar = {
      enable = true;
      persistent-workspaces = true;
      hidden = false;
      hwmon = "/sys/class/hwmon/hwmon2/temp1_input";
    };

    # Select touchscreen monitor by id
    # Find out monitor ID and names with "hyprctl monitors" command
    display.touchDevice = {
      enabled = true;
      # (Starts from 0) devIndex 0 is first monitor ID in "displays" list
      devIndex = 0;
      transform = 0;
      # ====== 0 horizontal
      # |||||| 1 vertical
    };

    vlc.enable = true;
    k3b.enable = true;

    blender.enable = true;
    reaper.enable = true;

    discord.enable = true;
    telegram.enable = true;
    viber.enable = true;

    insomnia.enable = true;
    minecraft-launchers.enable = true;

    # Select gpg keyid for git
    # keys located in ~/.local/share/.gnupg
    # To list the gpg signing keyid run:
    # gpg --list-secret-keys --keyid-format=long
    # Copy over id string after similar characters 'sec dsa2048/', text after '/'
    git = {
      enable = true;
      git-keyid = "92058DC9E2CF5F4C";
    };
  };

  home = {
    packages = lib.mkIf isNixOS (
      with pkgs;
      [
        guvcview
        # USE imv INSTEAD!
        # feh 
        mupdf
      ]
    );
  };
}
