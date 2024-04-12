{
  pkgs,
  lib,
  isNixOS,
  ...
}: {
  custom = {
    kbLayout = "jp";
    wifi.enable = true;
    displays = [
      {
        name = "HDMI-A-2";
        hyprland = "1920x1080@60,0x0,1,transform,1";
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
    };
    display.touchDevice = {
      enabled = true;
      # (Starts from 0) devIndex 0 is first monitor in "displays" list
      devIndex = 0;
      transform = 3;
    };
    gradience.enable = true;
    firefox.enable = true;
    wallust = {
      enable = true;
    };
    rofi = {
      enable = true;
      theme = "onedark";
    };
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
    reaper.enable = true;

    discord.enable = true;
    telegram.enable = true;
    viber.enable = true;

    insomnia.enable = true;
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
        st
        feh
        mupdf
        ffmpeg
        glibc
        zola
      ]
    );
  };

}
