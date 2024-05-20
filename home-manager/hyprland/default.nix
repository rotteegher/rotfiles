{
  config,
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.custom) displays display;
in
{
  imports = [
    ./idle.nix
    ./keybinds.nix
    ./lock.nix
    ./screenshot.nix
    ./startup.nix
    ./wallpaper.nix
    ./waybar.nix
  ];

  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    home = {
      sessionVariables = {
        HYPR_LOG = "/tmp/hyprland.log";
      };

      packages = with pkgs; [
        # hyprland shader switcher
        hyprshade

        # clipboard history
        cliphist
        wl-clipboard
      ];

      # shaders location config
      file.".config/hypr/shaders".source = ./shaders;
    };

    # Hyprland plugins go here
    wayland.windowManager.hyprland.plugins = [
      # touchscreen plugin
      # inputs.hyprgrass.packages.${pkgs.system}.default
    ];

    wayland.windowManager.hyprland.settings = {
      monitor =
        (lib.forEach displays ({ name, hyprland, ... }: "${name}, ${hyprland}"))
        ++ (lib.optional (host != "desktop") ",preferred,auto,auto");

      env = [
        "HYPRCURSOR_THEME,${config.home.pointerCursor.name}"
        "HYPRCURSOR_SIZE,${toString config.home.pointerCursor.size}"

      ];

      input = {
        kb_layout = config.custom.kbLayout;
        follow_mouse = 1;
        accel_profile = "flat";
        repeat_delay = 300;

        # Set config.custom.display setting index to specify which monitor is a touchscreen device via host specific configuration
        touchdevice = lib.mkIf display.touchDevice.enabled {
          enabled = true;
          transform = display.touchDevice.transform;
          output = (lib.elemAt displays display.touchDevice.devIndex).name;
        };

        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
        };
      };

      # hyprgrass touchscreen plugin settings
      # plugin.touch_gestures = {
      # The default sensitivity is probably too low on tablet screens,
      # I recommend turning it up to 4.0
      # sensitivity = 3.0;

      # must be >= 3
      # workspace_swipe_fingers = 3;

      # switching workspaces by swiping from an edge, this is separate from workspace_swipe_fingers
      # and can be used at the same time
      # possible values: l, r, u, or d
      # to disable it set it to anything else
      # workspace_swipe_edge = false;

      # in milliseconds
      # long_press_delay = 400;

      # experimental {
      #   # send proper cancel events to windows instead of hacky touch_up events,
      #   # NOT recommended as it crashed a few times, once it's stabilized I'll make it the default
      #   send_cancel = 0;
      # }
      # };

      # touchscreen
      gestures = {
        workspace_swipe = true;
        workspace_swipe_cancel_ratio = 0.15;
      };

      "$mod" = config.custom.hyprland.modkey;

      "$term" = "${config.custom.terminal.exec}";

      general =
        let
          gap = if host == "desktop" then 2 else 1;
        in
        {
          gaps_in = gap;
          gaps_out = gap;
          border_size = 2;
          layout = "master";
        };

      decoration = {
        rounding = 4;
        drop_shadow = host != "vm";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";

        # dim_inactive = true
        # dim_strength = 0.05

        blur = {
          # enabled = host != "vm";
          enabled = false;
          size = 2;
          passes = 3;
          new_optimizations = true;
        };

        # blurls = rofi
      };

      animations = {
        enabled = false;
        bezier = [
          "overshot, 0.05, 0.9, 0.1, 1.05"
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "smoothIn, 0.25, 1, 0.5, 1"
        ];

        # name, onoff, speed, curve, style
        # speed units is measured in 100ms
        animation = [
          "windows, 1, 5, overshot, slide"
          "windowsOut, 1, 4, smoothOut, slide"
          "windowsMove, 1, 4, smoothIn, slide"
          "layers, 1, 5, default, popin 80%"
          "border, 1, 5, default"
          # 1 loop every 5 minutes
          "borderangle, 1, ${toString (10 * 60 * 5)}, default, loop"
          "fade, 1, 5, smoothIn"
          "fadeDim, 1, 5, smoothIn"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
      };

      master = {
        new_is_master = false;
        mfact = "0.5";
        orientation = "left";
        smart_resizing = true;
      };

      binds = {
        workspace_back_and_forth = false;
      };

      misc = {
        disable_hyprland_logo = false;
        disable_splash_rendering = false;
        mouse_move_enables_dpms = false;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        key_press_enables_dpms = true;
        enable_swallow = false;
        swallow_regex = "^([Kk]itty|[Ww]ezterm)$";
        focus_on_activate = false;
      };

      debug.disable_logs = false;

      # bind workspaces to monitors
      workspace = pkgs.custom.lib.mapWorkspaces (
        { workspace, monitor, ... }: "${workspace}, monitor:${monitor}"
      ) displays;

      windowrulev2 = [
        # fix discord not detecting keyboard input
        "forceinput, class:^(discord)$, xwayland:0"
        # "dimaround,floating:1"
        "bordersize 5,fullscreen:1" # monocle mode
        "float,class:(wlroots)" # hyprland debug session
        "float,class:(Waydroid)"
      ];

      windowrule = [
        # do not idle while watching videos
        "idleinhibit fullscreen,firefox"
        "idleinhibit focus,YouTube"
        "idleinhibit focus,mpv"
      ];

      exec-once = [
        # clipboard manager
        "wl-paste --watch cliphist store"
      ];
      # source = "~/.config/hypr/hyprland-test.conf";
    };
    # hyprland crash reports
    custom.persist = {
      home.directories = [ ".cache/hyprland" ];
    };
  };
}
