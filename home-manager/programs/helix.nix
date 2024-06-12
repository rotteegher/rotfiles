{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.custom.helix.enable {
    home.packages = [pkgs.lldb pkgs.clang-tools];
    programs.helix = {
      enable = true;
      defaultEditor = config.custom.shell.defaultEditor == "hx";
      themes = {
        mtr = {
          "inherits" = "mellow";
          # "inherits" = "ferra";
          # "inherits" = "vim_dark_high_contrast";
          # "inherits" = "catppuccin_mocha";
          # "inherits" = "catppuccin_latte";
          "ui.background" = {fg = "none";};
        };
      };
      settings = {
        theme = "mtr";
        editor = {
          lsp.display-inlay-hints = true;
          true-color = true;
          line-number = "relative";
          mouse = true;
          rulers = [200];
          bufferline = "always";
        };
        keys.select = {
          X = ["extend_line_up" "extend_to_line_bounds"];
          A-x = "extend_to_line_bounds";
          C-y = "yank_to_clipboard";
        };
        keys.normal = {
          X = ["extend_line_up" "extend_to_line_bounds"];
          A-x = "extend_to_line_bounds";
          C-p = ["move_line_up" "scroll_up"];
          C-n = ["move_line_down" "scroll_down"];
          C-y = "yank_to_clipboard";
          esc = ["collapse_selection" "keep_primary_selection"]; # FIXME
        };
        editor.cursor-shape = {
          insert = "bar";
          # normal = "block";
          select = "underline";
        };
        editor.file-picker = {
          hidden = false;
        };
      };
    };
  };
}
