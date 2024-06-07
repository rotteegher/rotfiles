{
  config,
  lib,
  host,
  isLaptop,
  pkgs,
  ...
}:
let
  hyprlandCfg = config.wayland.windowManager.hyprland;
in
{
  options.custom = {
    display.touchDevice = {
      enabled = lib.mkEnableOption "Enable Touchscreen device support" // {
        default = false;
      };
      transform = lib.mkOption {
        type = lib.types.int;
        default = 0;
        description = ''
          Transform the input of a touchscreen to match the monitor rotation
          This will be done automatically when #3544 lands.
          https://github.com/hyprwm/Hyprland/pull/3544

          normal (no transforms) -> 0
          90 degrees -> 1
          180 degrees -> 2
          270 degrees -> 3
          flipped -> 4
          flipped + 90 degrees -> 5
          flipped + 180 degrees -> 6
          flipped + 270 degrees -> 7
        '';
      };
      devIndex = lib.mkOption {
        type = lib.types.int;
        default = 0;
        description = ''
          (Starts from 0) specify which monitor in displays list
          is to be considered touchdevice an input.touchdevice.output by hyprland
          https://wiki.hyprland.org/Configuring/Variables/#touchdevice
        '';
      };
    };
    displays = lib.mkOption {
      type =
        with lib.types;
        listOf (submodule {
          options = {
            name = lib.mkOption {
              type = str;
              description = "The name of the display, e.g. eDP-1";
            };
            hyprland = lib.mkOption {
              type = str;
              description = ''
                Hyprland config for the monitor, see
                https://wiki.hyprland.org/Configuring/Monitors/

                e.g. 3440x1440@160,1440x1080,1
              '';
            };
            workspaces = lib.mkOption {
              type = listOf int;
              description = "List of workspace strings";
            };
          };
        });
      default = [ ];
      description = "Config for new displays";
    };

    hyprland = {
      autostart = lib.mkEnableOption "Autostart hyprland from tty" // {
        default = true;
      };
      lock = lib.mkEnableOption "locking of host" // {
        default = isLaptop;
      };
      qtile = lib.mkEnableOption "qtile like behavior for workspaces";
      plugin = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "hyprnstack" ]);
        description = "Plugin to enable for hyprland";
        default = null;
      };
    };

    waybar = {
      enable = lib.mkEnableOption "waybar" // {
        default = hyprlandCfg.enable;
      };
      hwmon = lib.mkOption {
        type = lib.types.str;
        default = "/sys/class/hwmon/hwmon0/temp1_input";
        description = "Temperature monitor device file";
      };
      config = lib.mkOption {
        type = lib.types.submodule { freeformType = (pkgs.formats.json { }).type; };
        default = { };
        description = "Additional waybar config (wallust templating can be used)";
      };
      idle-inhibitor = lib.mkEnableOption "Idle inhibitor" // {
        default = host == "desktop";
      };
      persistent-workspaces = lib.mkEnableOption "Persistent workspaces" // {
        default = true;
      };
      hidden = lib.mkEnableOption "Hidden waybar by default";
    };
  };
}
