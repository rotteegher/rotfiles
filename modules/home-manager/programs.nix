{
  host,
  isNixOS,
  lib,
  pkgs,
  ...
}:
{
  options.custom = {
    hyprland = {
      modkey = lib.mkOption {
        type = lib.types.str;
        default = "SUPER";
      };
    };

    discord.enable = lib.mkEnableOption "discord" // {
      default = false;
    };
    insomnia.enable = lib.mkEnableOption "discord" // {
      default = true;
    };
    firefox.enable = lib.mkEnableOption "firefox" // {
      default = true;
    };
    rofi.enable = lib.mkEnableOption "rofi" // {
      default = true;
    };
    k3b.enable = lib.mkEnableOption "k3b" // {
      default = false;
    };
    telegram.enable = lib.mkEnableOption "telegram-desktop" // {
      default = false;
    };
    viber.enable = lib.mkEnableOption "viber" // {
      default = false;
    };
    reaper.enable = lib.mkEnableOption "reaper" // {
      default = false;
    };
    blender.enable = lib.mkEnableOption "blender" // {
      default = false;
    };
    deadbeef.enable = lib.mkEnableOption "deadbeef" // {
      default = host == "desktop";
    };
    helix.enable = lib.mkEnableOption "helix" // {
      default = true;
    };
    kitty.enable = lib.mkEnableOption "kitty" // {
      default = isNixOS;
    };
    obs-studio.enable = lib.mkEnableOption "obs-studio" // {
      default = isNixOS && host == "desktop";
    };
    pathofbuilding.enable = lib.mkEnableOption "pathofbuilding" // {
      default = isNixOS;
    };
    rclip.enable = lib.mkEnableOption "rclip";
    trimage.enable = lib.mkEnableOption "trimage";
    vlc.enable = lib.mkEnableOption "vlc";
    wezterm.enable = lib.mkEnableOption "wezterm" // {
      default = isNixOS;
    };

    # MINECRAFT PRISMLAUNCHER
    minecraft-launchers.enable = lib.mkEnableOption "minecraft-prismlauncher + others?" // {
      default = false;
    };
    # WALLUST
    wallust = with lib.types; {
      enable = lib.mkEnableOption "wallust" // {
        default = true;
      };
      colorscheme = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The colorscheme to use. If null, will use the default colorscheme from the wallpaper.";
      };
      nixJson = lib.mkOption {
        type = lib.types.submodule { freeformType = (pkgs.formats.json { }).type; };
        default = { };
        description = "Data to be written to nix.json for use in other programs at runtime.";
      };
      templates = lib.mkOption {
        type = attrsOf (submodule {
          options = {
            text = lib.mkOption {
              type = str;
              description = "Content of the template file";
            };
            target = lib.mkOption {
              type = str;
              description = "Absolute path to the file to write the template (after templating), e.g. ~/.config/dunst/dunstrc";
            };
          };
        });
        default = [ ];
        description = ''
          Example templates, which are just a file you wish to apply `wallust` generated colors to.
          template = "dunstrc"
        '';
      };
    };
  };
}
