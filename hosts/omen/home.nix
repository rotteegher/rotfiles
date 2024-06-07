{
  pkgs,
  lib,
  isNixOS,
  ...
}:
{
  custom = {
    wifi.enable = true;
    battery.enable = true;
    backlight.enable = true;
    displays = [
      {
        name = "eDP-1";
        hyprland = "1920x1080@144,0x0,1";
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
      modkey = "SUPER";
      autostart = false;
      lock = false;
    };
    display.touchDevice = {
      enabled = false;
      # (Starts from 0) devIndex 0 is first monitor in "displays" list
      devIndex = 0;
    };
    firefox.enable = true;
    wallust = {
      enable = true;
    };
    rofi.enable = true;
    # rclip.enable = false;
    waybar = {
      enable = true;
      persistent-workspaces = true;
      hidden = false;
      hwmon = "/sys/class/hwmon/hwmon7/temp1_input";
    };

    # vlc.enable = true;
    # k3b.enable = true;
    helix.enable = true;

    # blender.enable = true;
    # reaper.enable = false;

    discord.enable = true;
    telegram.enable = true;
    # viber.enable = true;

    minecraft-launchers.enable = true;

    # To list the gpg signing keyid run:
    # gpg --list-secret-keys --keyid-format=long
    # Copy over id string after similar characters 'sec dsa2048/'
    git = {
      enable = true;
      git-keyid = "92058DC9E2CF5F4C";
    };
    terminal.size = 12;
    persist = {
      home.directories = [
        "Downloads"
        "Documents"
        "Videos"
      ];
    };
  };

  home = {
    packages = lib.mkIf isNixOS (
      with pkgs;
      [
        # gimp
        # kdenlive
        feh
        mupdf
        ffmpeg
        libgcc
        glibc
      ]
    );
  };
}
