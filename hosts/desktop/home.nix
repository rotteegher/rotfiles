{ pkgs, lib, isNixOS, ... }: {
  custom = {
    kbLayout = "jp";
    wifi.enable = true;
    backlight.enable = true;

    # Config for the hyprland monitors
    # https://wiki.hyprland.org/Configuring/Monitors/
    # 
    # monitorv2 = (lib.forEach displays
    #   ({display_name_output, mode, position, addreserved, scale, transform, ... }: {
    #     output = display_name_output;
    #     inherit mode position addreserved scale transform;
    #   })
    # );
    # 
    # Example:
    # output = "DP-2";
    # mode = "3440x1440@200";
    # position = "0x0";
    # addreserved = "1600, 0, 0, 0";
    # scale = 1;
    # transform = 3;

    displays = [
      {
        display_name_output = "DP-3";
        mode = "2560x1080@200";
        position = "0x0";
        addreserved = "0, 0, 0, 600,";
        scale = 1.0;
        transform = 0;
        workspace_names = [ "1" "2" "3" "4" "a" "s" "d" "c" ];
        workspaces = [ 1 2 3 4 8 9 10 11 ];
      }
      {
        display_name_output = "DP-2";
        mode = "3440x1440@200";
        position = "2560x0";
        addreserved = "0, 0, 0, 1650";
        scale = 1.0;
        transform = 0;
        workspace_names = [ "q" "w" "e"];
        workspaces = [ 5 6 7];
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
    packages = lib.mkIf isNixOS (with pkgs; [ guvcview krita inkscape ]);
  };
}
