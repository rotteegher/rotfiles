{
  config,
  lib,
  ...
}: let
  cfg = config.rot.helix;
  in {
    config = lib.mkIf cfg.enable {
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
        settings = {
          theme = "papercolor-light";
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
          };
          keys.normal = {
            X = ["extend_line_up" "extend_to_line_bounds"];
            A-x = "extend_to_line_bounds";
            C-p = ["move_line_up" "scroll_up"];
            C-n = ["move_line_down" "scroll_down"];
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
