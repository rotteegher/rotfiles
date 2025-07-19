{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.rot.kitty.enable {
    programs.kitty = with config.rot.terminal; {
      enable = true;
      theme = "Catppuccin-Mocha";
      font = {
        name = font;
        size = size;
      };
      settings = {
        enable_audio_bell = false;
        copy_on_select = "clipboard";
        scrollback_lines = 10000;
        update_check_interval = 0;
        window_margin_width = padding;
        single_window_margin_width = padding;
        tab_bar_edge = "top";
        background_opacity = toString opacity;
        confirm_os_window_close = 0;
        font_features = "JetBrainsMonoNerdFontComplete-Regular +zero";
        shell =
          if (config.rot.shell.interactive == "fish")
          then "${pkgs.fish}/bin/fish"
          else ".";
      };
    };

    home.shellAliases = {
      # change color on ssh
      ssh = "kitten ssh --kitten=color_scheme=Dracula";
    };
  };
}

