{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.custom.helix.enable {
    home.packages = [
      pkgs.lldb
      pkgs.clang-tools
    ];
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
          "ui.background" = {
            fg = "none";
          };
        };
      };
      languages = {
        language-server.rust-analyzer.command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        language-server.rust-analyzer.config.diagnostics.disabled = [
          "inactive-code"
          "unlinked-file"
        ];
      };
      settings = {
        theme = "mtr";
        editor = {
          lsp.display-messages = true;
          lsp.display-inlay-hints = true;
          statusline = {
            center = [ "file-absolute-path" ];
          };
          true-color = true;
          line-number = "relative";
          mouse = true;
          rulers = [ 200 ];
          bufferline = "always";
        };
        keys.select = {
          X = [
            "extend_line_up"
            "extend_to_line_bounds"
          ];
          A-x = "extend_to_line_bounds";
          C-y = "yank_to_clipboard";
        };
        keys.normal = {
          # until fixed ISSUE: https://github.com/helix-editor/helix/issues/10389
          # Workaround for ukrainian lagnuage key remap
          # українська мапа клавіатури:

          # перший ряд
          "й" = ["replay_macro"]; # q
          "ц" = ["move_next_word_start"]; # w
          "у" = ["move_next_word_end"]; # e
          "к" = ["replace"]; # r
          "е" = ["find_till_char"]; # t
          "н" = ["yank_to_clipboard"]; # y
          "г" = []; "C-г" = ["page_cursor_half_up"]; # u
          "ш" = ["insert_mode"]; "C-ш" = ["jump_forward"]; # i
          "щ" = ["open_below"]; "C-щ" = ["Jump_backward"]; # o
          "з" = ["paste_clipboard_after"]; # p
          "х" = []; # @
          "ї" = []; # [

          "Й" = ["record_macro"]; # Q
          "Ц" = ["move_next_long_word_start"]; # W
          "У" = []; # E
          "К" = ["replace_selections_with_clipboard"]; # R
          "Е" = ["till_prev_char"]; # T
          "Н" = ["yank_main_selection_to_clipboard"]; # Y
          "Г" = []; # U
          "Ш" = []; # I
          "Щ" = []; # O
          "З" = ["paste_clipboard_before"]; # P
          "Х" = []; # `
          "Ї" = []; # {

          # другий ряд 
          "ф" = ["append_mode"]; # a 
          "і" = ["select_regex"]; "C-і" = ["save_selection"]; "A-і" = ["split_selection_on_newline"]; # s 
          "в" = ["delete_selection"]; "C-в" = ["page_cursor_half_down"]; # d 
          "а" = ["find_next_char"]; "C-а" = ["page_down"]; # f 
          "п" = []; # g 
          "р" = ["move_char_left"]; # h 
          "о" = ["move_visual_line_down"]; # j 
          "л" = ["move_visual_line_up"]; # k 
          "д" = ["move_char_right"]; # l 
          "ж" = []; # ; 
          "є" = []; # : 
          "ґ" = []; # ] 

          "Ф" = []; # A
          "І" = []; # S
          "В" = []; # D
          "А" = ["find_prev_char"]; # F
          "П" = ["goto_line"]; # G
          "Р" = []; # H
          "О" = []; # J
          "Л" = []; # K
          "Д" = []; # L/R
          "Ж" = []; # +
          "Є" = []; # *
          "Ґ" = []; # }

          # третій ряд
          "я" = []; # z
          "ч" = []; # x
          "с" = []; # c
          "м" = []; # v
          "и" = ["move_prev_word_start"];  "C-и" = ["page_up"]; # b
          "т" = []; # n
          "ь" = []; # m
          "б" = []; # ,
          "ю" = []; # .
          "." = ["global_search"]; # /
        
          "Я" = []; # Z
          "Ч" = []; # X
          "С" = []; #           "М" = []; # V
          "И" = ["move_prev_long_word_start"]; # B
          "Т" = []; # N
          "Ь" = []; # M
          "Б" = []; # <
          "Ю" = []; # >
          "," = []; # ?

          
          X = [
            "extend_line_up"
            "extend_to_line_bounds"
          ];
          A-x = "extend_to_line_bounds";
          C-p = [
            "move_line_up"
            "scroll_up"
          ];
          C-n = [
            "move_line_down"
            "scroll_down"
          ];
          C-y = "yank_to_clipboard";
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ]; # FIXME
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
