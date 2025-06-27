{ pkgs, lib, isNixOS, ... }: {
  custom = {
    kbLayout = "jp";
    wifi.enable = true;
    backlight.enable = true;
    displays = [
      {
        display_name = "DP-3";
        hyprland = "addreserved, 0, 0, 0, 600, 2560x1080@200.01,0x0,1";
        workspace_names = [ "1" "4" "a" "s" "d" ];
        workspaces = [ 1 4 8 9 10 ];
      }
      {
        display_name = "DP-2";
        hyprland = "3440x1440@180,-2560x0,1,";
        workspace_names = [ "2" "3" "q" "w" "e"];
        workspaces = [ 2 3 5 6 7];
      }
    ];
    terminal.size = 8;

    wallust.colorscheme = "base16-embers";

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
    k3b.enable = false;

    kiwix.enable = true;

    blender.enable = true;
    reaper.enable = true;

    discord.enable = true;
    telegram.enable = true;

    insomnia.enable = true;
    minecraft-launchers.enable = true;

    irc.enable = true;

    # Select gpg keyid for git
    # keys located in ~/.local/share/.gnupg
    # To list the gpg signing keyid run:
    # gpg --list-secret-keys --keyid-format=long
    # Copy over id string after similar characters 'sec dsa2048/', text after '/'
    git = {
      enable = true;
      git-keyid = "80A56B918CFA5155";
    };
  };
  home = {
    packages = lib.mkIf isNixOS (with pkgs; [ guvcview krita inkscape custom.wl_shimeji ]);
  };
}
