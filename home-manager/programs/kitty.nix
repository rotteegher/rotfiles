{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.kitty;
  inherit (config.custom) terminal;
in
  lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      themeFile = "tokyo_night_storm";
      font = {
        name = terminal.font;
        inherit (terminal) size;
      };
      settings = {
        enable_audio_bell = false;
        copy_on_select = "clipboard";
        scrollback_lines = 10000;
        update_check_interval = 0;
        window_margin_width = terminal.padding;
        single_window_margin_width = terminal.padding;
        tab_bar_edge = "top";
        background_opacity = terminal.opacity;
        confirm_os_window_close = 0;
      };
      keybindings = {
        "ctrl+shift+equal" = "change_font_size all -2.0";
        "ctrl+shift+^" = "change_font_size all +2.0";
        "ctrl+shift+0" = "change_font_size all +2.0";
      };
    };

    home.shellAliases = {
      # change color on ssh
      ssh = "kitten ssh --kitten=color_scheme=Dracula";
    };
  }
