{
  config,
  lib,
  pkgs,
  ...
}:
let
  pamixer = lib.getExe pkgs.pamixer;
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    bind =
      [
        #GLOBAL
        ", mouse:276, pass, ^(TeamSpeak 3)$"
        
        # Exec
        "$mod, Return, exec, $term"
        "$mod_SHIFT, Return, exec, rofi -show drun"
        # Kill
        "$mod, BackSpace, killactive,"
        "$mod_CTRL, BackSpace, exec, hyprctl kill"
        # File
        "$mod, b, exec, nemo ~/Downloads"

        # Firefox
        "$mod_CTRL, f, exec, firefox"
        "$mod_SHIFT, f, exec, firefox --private-window"

        # exit hyprland
        "$mod_CTRL, c, exit,"

        ''CTRL_ALT, Delete, exec, rofi -show power-menu -font "${config.custom.fonts.monospace} 14" -modi power-menu:rofi-power-menu''
        "$mod_CTRL, v, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        # reset monitors
        "CTRL_SHIFT, Escape, exec, hypr-monitors"

        # reset input language
        "$mod_SHIFT, z, exec, fcitx5-remote -s keyboard-jp"

        "$mod, Escape, killactive"

        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        "$mod_SHIFT, h, movewindow, l"
        "$mod_SHIFT, l, movewindow, r"
        "$mod_SHIFT, k, movewindow, u"
        "$mod_SHIFT, j, movewindow, d"

        # Switch workspaces with mainMod
        # +
        # 1234 -> 1|2|3|4
        # qwe  -> 5|6|7
        # asd  -> 8|9|10
        "$mod, 1, workspace, 1" # 1
        "$mod, 2, workspace, 2" # 2
        "$mod, 3, workspace, 3" # 3
        "$mod, 4, workspace, 4" # 4

        "$mod, 5, workspace, 5" # 5
        "$mod, q, workspace, 5" # q for 5

        "$mod, 6, workspace, 6" # 6
        "$mod, w, workspace, 6" # w for 6

        "$mod, 7, workspace, 7" # 7
        "$mod, e, workspace, 7" # e for 7

        "$mod, 8, workspace, 8" # 8
        "$mod, a, workspace, 8" # a for 8

        "$mod, 9, workspace, 9" # 9
        "$mod, s, workspace, 9" # s for 9

        "$mod, 0, workspace, 10" # 10
        "$mod, d, workspace, 10" # d for 10

        # Move active window to a workspace with mainMod + SHIFT
        # +
        # 1234 -> 1|2|3|4
        # qwe  -> 5|6|7
        # asd  -> 8|9|10
        "$mod_SHIFT, 1, movetoworkspacesilent, 1" # 1
        "$mod_SHIFT, 2, movetoworkspacesilent, 2" # 2
        "$mod_SHIFT, 3, movetoworkspacesilent, 3" # 3
        "$mod_SHIFT, 4, movetoworkspacesilent, 4" # 4

        "$mod_SHIFT, 5, movetoworkspacesilent, 5" # 5
        "$mod_SHIFT, q, movetoworkspacesilent, 5" # q for 5

        "$mod_SHIFT, 6, movetoworkspacesilent, 6" # 6
        "$mod_SHIFT, w, movetoworkspacesilent, 6" # w for 6

        "$mod_SHIFT, 7, movetoworkspacesilent, 7" # 7
        "$mod_SHIFT, e, movetoworkspacesilent, 7" # e for 7

        "$mod_SHIFT, 8, movetoworkspacesilent, 8" # 8
        "$mod_SHIFT, a, movetoworkspacesilent, 8" # a for 8

        "$mod_SHIFT, 9, movetoworkspacesilent, 9" # 9
        "$mod_SHIFT, s, movetoworkspacesilent, 9" # s for 9

        "$mod_SHIFT, 0, movetoworkspacesilent, 10" # 10
        "$mod_SHIFT, d, movetoworkspacesilent, 10" # d for 10

        # "$mod_SHIFT, b, layoutmsg, swapwithmaster"

        # focus the previous / next desktop in the current monitor (DE style)
        "$mod_SHIFT_CTRL, h, workspace, m-1"
        "$mod_SHIFT_CTRL, l, workspace, m+1"

        # monocle mode
        "$mod, z, fullscreen, 1"

        # fullscreen
        "$mod, f, fullscreen, 0"
        "$mod_SHIFT_CTRL, f, fakefullscreen"

        # floating
        "$mod, g, togglefloating"

        # sticky
        "$mod_CTRL, s, pin"

        # focus next / previous monitor
        "$mod, Left, focusmonitor, -1"
        "$mod, Right, focusmonitor, +1"

        # resize windows
        "$mod_CTRL, h, resizeactive, -50 0"
        "$mod_CTRL, j, resizeactive, 0 50"
        "$mod_CTRL, k, resizeactive, 0 -50"
        "$mod_CTRL, l, resizeactive, 50 0"

        # # move to next / previous monitor
        # "$mod_SHIFT, Left, movewindow, ${
        #   if lib.length displays < 3
        #   then "mon:-1"
        #   else "mon:l"
        # }"
        # "$mod_SHIFT, Right, movewindow, ${
        #   if lib.length displays < 3
        #   then "mon:+1"
        #   else "mon:r"
        # }"
        # "$mod_SHIFT, Up, movewindow, ${
        #   if lib.length displays < 3
        #   then "mon:-1"
        #   else "mon:u"
        # }"
        # "$mod_SHIFT, Down, movewindow, ${
        #   if lib.length displays < 3
        #   then "mon:+1"
        #   else "mon:d"
        # }"

        "ALT, Tab, cyclenext"
        "ALT_SHIFT, Tab, cyclenext, prev"

        # switches to the next / previous window of the same class
        # hardcoded to SUPER so it doesn't clash on VM
        "SUPER, Tab, exec, hypr-same-class next"
        "SUPER_SHIFT, Tab, exec, hypr-same-class prev"

        # picture in picture mode
        "$mod, p, exec, hypr-pip"

        # add / remove master windows
        "$mod, m, layoutmsg, addmaster"
        "$mod_SHIFT, m, layoutmsg, removemaster"

        # rotate via switching master orientation
        "$mod, r, layoutmsg, orientationcycle left top"

        # reload config
        "$mod_CTRL, r, exec, hyprctl reload"

        # Scroll through existing workspaces with mainMod + scroll
        "$mod, mouse_down, workspace, e-1"
        "$mod, mouse_up, workspace, e+1"

        # dunst controls
        "$mod, grave, exec, dunstctl history-pop"

        # switching wallpapers or themes
        "$mod, apostrophe, exec, imv-wallpaper"
        "$mod_SHIFT, comma, exec, rofi-wallust-theme"

        # special keys
        # "XF86AudioPlay, mpvctl playpause"

        # audio
        ",XF86AudioLowerVolume, exec, ${pamixer} -d 5"
        ",XF86AudioRaiseVolume, exec, ${pamixer} -i 5"
        ",XF86AudioMute, exec, ${pamixer} -t"

        "$mod, n, exec, hypr-wallpaper"
      ]
      ++ lib.optionals config.custom.backlight.enable [
        ",XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} set 5%-"
        ",XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} set +5%"
      ];

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };
}
