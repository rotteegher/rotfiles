{
  pkgs,
  lib,
  isNixOS,
  ...
}: {

  rot = {
    displays = [
      {
        name = "HDMI-A-5";
        hyprland = "1920x1080@60,0x0,1";
        workspaces = [ 1 3 6 7 8 ];
      }
      # second element by index 1 is set to be a touchscreen monitor
      {
        name = "HDMI-A-4";
        hyprland = "1920x1080@60,1910x1080,1.333";
        workspaces = [ 2 4 5 9 10 ];
      }
    ];
    firefox.enable = true;
    hyprland.plugin = "hyprnstack";
    wallust.enable = true;
    rofi.enable = true;
    rclip.enable = false;
    waybar = {
      enable = true;
      theme = "transparent";
      persistent-workspaces = true;
    };
    pathofbuilding.enable = true;
    vlc.enable = true;
    k3b.enable = true;
    helix.enable = true;

    blender.enable = true;
    reaper.enable = false;

    discord.enable = true;


    minecraft-launchers.enable = true;

    # To list the gpg signing keyid run:
    # gpg --list-secret-keys --keyid-format=long
    # Copy over id string after similar characters 'sec dsa2048/'
    git = {
      enable = true;
      git-keyid = "AD44C88C5EC758ED";
    };
    terminal.exec = "kitty";
  };


  home = {
    packages = lib.mkIf isNixOS (
      with pkgs; [
        gimp
        # kdenlive
        feh
        mupdf
        ffmpeg
        cmatrix
        libgcc
        glibc
        zola
        fspy
        # vial  
      ]
    );
  };

  # required vial to work?
  # services.udev.extraRules = ''KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"'';
}
