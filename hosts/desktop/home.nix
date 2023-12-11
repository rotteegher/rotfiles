{
  pkgs,
  lib,
  isNixOS,
  ...
}: {
  rot = {
    displays = [
      {
        name = "HDMI-A-1";
        hyprland = "1920x1080@60,1920x1080,1";
        workspaces = [1 2 3 4 5 6 7 8 9 10];
      }
    ];
    hyprland.plugin = "hyprnstack";
    rclip.enable = true;
    waybar = {
      # theme = "transparent";
      # persistent-workspaces = true;
    };
    pathofbuilding.enable = true;
    vlc.enable = true;
    helix.enable = true;

    # To list the gpg signing keyid run:
    # gpg --list-secret-keys --keyid-format=long
    # Copy over id string after similar characters 'sec dsa2048/'
    git = {
      enable = true;
      git-keyid = "AD44C88C5EC758ED";
    };
  };

  home = {
    packages = lib.mkIf isNixOS (
      with pkgs; [
        ffmpeg
        neofetch
        # vial  
      ]
    );
  };

  # required vial to work?
  # services.udev.extraRules = ''KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"'';
}
