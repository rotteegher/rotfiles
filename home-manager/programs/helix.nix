{
  config,
  lib,
  pkgs,
  ...
}: {
    config = lib.mkIf config.rot.helix.enable {
      home.packages = [ pkgs.lldb ];
      programs.helix = {
        enable = true;
        languages = {
          language = [{
            name = "rust";
            auto-format = true;
            scope = "source.rs";
            file-types = ["rs"];
            indent = { 
              tab-width = 4;
              unit = "    ";
            };
            language-id = "rust";
            roots = [ "Cargo.lock" "Cargo.toml"];
            language-servers = ["rust-analyzer"];
          }];
        };
        themes = {
          mtr = {
            "inherits" = "mellow";
            "ui.background" = { fg = "none"; };
          };
        };
        settings = {
          theme = "mtr";
          editor = {
            lsp.display-inlay-hints = true;
            true-color = true;
            line-number = "relative";
            mouse = true;
            rulers = [80];
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
            # esc = ["collapse_selection" "keep_primary_selection"];
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
