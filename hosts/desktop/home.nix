{
  pkgs,
  lib,
  isNixOS,
  ...
}: {
  custom = {
    wifi.enable = true;
    displays = [
      {
        name = "HDMI-A-5";
        hyprland = "1920x1080@60,0x0,1";
        workspaces = [1 3 6 7 8];
      }
      {
        name = "HDMI-A-4";
        hyprland = "1920x1080@60,1910x1080,1.333";
        workspaces = [2 4 5 9 10];
      }
    ];
    display.touchDevice = {
      enabled = true;
      # (Starts from 0) devIndex 0 is first monitor in "displays" list
      devIndex = 1;
    };
    gradience.enable = false;
    firefox.enable = true;
    wallust = {
      enable = true;
    };
    rofi.enable = true;
    rclip.enable = false;
    waybar = {
      enable = true; 
      persistent-workspaces = true;
      hidden = false;
    };

    vlc.enable = true;
    k3b.enable = true;
    helix.enable = true;

    blender.enable = true;
    reaper.enable = false;

    discord.enable = true;
    telegram.enable = true;
    viber.enable = true;

    minecraft-launchers.enable = true;

    # To list the gpg signing keyid run:
    # gpg --list-secret-keys --keyid-format=long
    # Copy over id string after similar characters 'sec dsa2048/', text after '/'
    git = {
      enable = true;
      git-keyid = "92058DC9E2CF5F4C";
    };
    terminal.exec = "kitty";
  };

  home = {
    packages = lib.mkIf isNixOS (
      with pkgs; [
        # gimp
        # kdenlive
        feh
        mupdf
        ffmpeg
        libgcc
        glibc
        zola
      ]
    );
  };

}
