{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.custom) displays;
  rofi = lib.getExe pkgs.rofi;
  pamixer = lib.getExe pkgs.pamixer;
  qtile_like = config.custom.hyprland.qtile;
in {
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    bind = let
      workspace_keybinds = lib.flatten ((pkgs.custom.lib.mapWorkspaces ({
        workspace,
        key,
        ...
      }:
        if qtile_like
        then [
          # Switch workspaces with mainMod + [0-9]
          "$mod, ${key}, focusworkspaceoncurrentmonitor, ${workspace}"
          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mod_SHIFT, ${key}, movetoworkspace, ${workspace}"
          "$mod_SHIFT, ${key}, focusworkspaceoncurrentmonitor, ${workspace}"
        ]
        else [
          # Switch workspaces with mainMod + [0-9]
          "$mod, ${key}, workspace, ${workspace}"
          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mod_SHIFT, ${key}, movetoworkspace, ${workspace}"
        ]))
      displays);
    in
      [
        "$mod, Return, exec, $term"
        "$mod_SHIFT, Return, exec, rofi -show drun"
        "$mod, BackSpace, killactive,"
        "$mod, e, exec, nemo ~/Downloads"
        "$mod_SHIFT, e, exec, $term yazi ~/Downloads"
        "$mod, w, exec, brave"
        "$mod_SHIFT, w, exec, brave --incognito"
        # "$mod, v, exec, $term nvim"
        "$mod_SHIFT, v, exec, code"

        # exit hyprland
        "$mod_SHIFT, c, exit,"

        ''CTRL_ALT, Delete, exec, rofi -show power-menu -font "${config.custom.fonts.monospace} 14" -modi power-menu:rofi-power-menu''
        "$mod_CTRL, v, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        # reset monitors
        "CTRL_SHIFT, Escape, exec, hypr-monitors"

        # reset input language
        "$mod, Escape, exec, fcitx5-remote -s keyboard-jp"

        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        "$mod_SHIFT, h, movewindow, l"
        "$mod_SHIFT, l, movewindow, r"
        "$mod_SHIFT, k, movewindow, u"
        "$mod_SHIFT, j, movewindow, d"

        # Switch workspaces with mainMod + [0-9]
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mod_SHIFT, 1, movetoworkspacesilent, 1"
        "$mod_SHIFT, 2, movetoworkspacesilent, 2"
        "$mod_SHIFT, 3, movetoworkspacesilent, 3"
        "$mod_SHIFT, 4, movetoworkspacesilent, 4"
        "$mod_SHIFT, 5, movetoworkspacesilent, 5"
        "$mod_SHIFT, 6, movetoworkspacesilent, 6"
        "$mod_SHIFT, 7, movetoworkspacesilent, 7"
        "$mod_SHIFT, 8, movetoworkspacesilent, 8"
        "$mod_SHIFT, 9, movetoworkspacesilent, 9"
        "$mod_SHIFT, 0, movetoworkspacesilent, 10"

        "$mod, b, layoutmsg, swapwithmaster"

        # focus the previous / next desktop in the current monitor (DE style)
        "$mod_SHIFT_CTRL, h, workspace, m-1"
        "$mod_SHIFT_CTRL, l, workspace, m+1"

        # monocle mode
        "$mod, z, fullscreen, 1"

        # fullscreen
        "$mod, f, fullscreen, 0"
        "$mod_SHIFT, f, fakefullscreen"

        # floating
        "$mod, g, togglefloating"

        # sticky
        "$mod, s, pin"

        # focus next / previous monitor
        "$mod, Left, focusmonitor, -1"
        "$mod, Right, focusmonitor, +1"

        # resize windows
        "$mod SHIFT, right, resizeactive, 50 0"
        "$mod SHIFT, left, resizeactive, -50 0"
        "$mod SHIFT, up, resizeactive, 0 -50"
        "$mod SHIFT, down, resizeactive, 0 50"

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

        # Scroll through existing workspaces with mainMod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"


        # dunst controls
        "$mod, grave, exec, dunstctl history-pop"

        # switching wallpapers or themes
        "$mod, apostrophe, exec, imv-wallpaper"
        "$mod_SHIFT, apostrophe, exec, rofi-wallust-theme"

        # special keys
        # "XF86AudioPlay, mpvctl playpause"

        # audio
        ",XF86AudioLowerVolume, exec, ${pamixer} -d 5"
        ",XF86AudioRaiseVolume, exec, ${pamixer} -i 5"
        ",XF86AudioMute, exec, ${pamixer} -t"

        # waybar
        "$mod, C, exec, pkill -SIGUSR1 waybar"
        "$mod, V, exec, launch-waybar"
        "$mod, N, exec, hypr-wallpaper"

      ]
      ++ lib.optionals config.custom.wezterm.enable ["$mod, q, exec, wezterm start"]
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
