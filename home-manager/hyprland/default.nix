{
  config,
  host,
  isLaptop,
  lib,
  pkgs,
  inputs,
  ...
}: let
  displays = config.custom.displays;
  display = config.custom.display;
in {
  imports = [
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
        XCURSOR_SIZE = "${toString config.home.pointerCursor.size}";
        HYPR_LOG = "/tmp/hypr/$(command ls -t /tmp/hypr/ | grep -v lock | head -n 1)/hyprland.log";
      };

      packages = with pkgs; [
        xdg-utils

        # hyprland shaders
        hyprshade
        hyprpaper

        # clipboard history
        cliphist
        wl-clipboard
      ];

      file.".config/hypr/shaders".source = ./shaders;
    };

    # Plugins
    wayland.windowManager.hyprland.plugins = [
      # touchscreen plugin
      # inputs.hyprgrass.packages.${pkgs.system}.default
    ];

    wayland.windowManager.hyprland.settings = lib.mkMerge [
      {
        monitor =
          (lib.forEach displays ({
            name,
            hyprland,
            ...
          }: "${name}, ${hyprland}"))
          ++ (lib.optional (host != "desktop") ",preferred,auto,auto");

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

        # touchscreen
        gestures = {
          workspace_swipe = true;
          workspace_swipe_cancel_ratio = 0.15;
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

        "$mod" = config.custom.hyprland.modkey;

        "$term" = "${config.custom.terminal.exec}";

        general = let
          gap =
            if host == "desktop"
            then 4
            else 2;
        in {
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
          enabled = host != "vm";
          bezier = [
            "overshot, 0.05, 0.9, 0.1, 1.05"
            "smoothOut, 0.36, 0, 0.66, -0.56"
            "smoothIn, 0.25, 1, 0.5, 1"
          ];

          animation = [
            "windows, 1, 5, overshot, slide"
            "windowsOut, 1, 4, smoothOut, slide"
            "windowsMove, 1, 4, smoothIn, slide"
            "border, 1, 5, default"
            "fade, 1, 5, smoothIn"
            "fadeDim, 1, 5, smoothIn"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
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
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          animate_manual_resizes = true;
          animate_mouse_windowdragging = true;
          key_press_enables_dpms = true;
          enable_swallow = false;
          swallow_regex = "^([Kk]itty|[Ww]ezterm)$";
        };

        # bind workspaces to monitors
        workspace = lib.concatMap ({
          name,
          workspaces,
          ...
        }:
          lib.forEach workspaces (ws: "${toString ws}, monitor:${name}"))
        displays;

        windowrulev2 = [
          # fix discord not detecting keyboard input
          "forceinput, class:^(discord)$, xwayland:0"
          # "dimaround,floating:1"
          "bordersize 5,fullscreen:1" # monocle mode
          "float,class:(wlroots)" # hyprland debug session
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
      }
      # handle trackpad settings
      (lib.optionalAttrs isLaptop {
        gestures = {
          workspace_swipe = true;
        };

        # handle laptop lid
        bindl = [
          # ",switch:on:Lid Switch, exec, hyprctl keyword monitor ${displayCfg.monitor1}, 1920x1080, 0x0, 1"
          # ",switch:off:Lid Switch, exec, hyprctl monitor ${displayCfg.monitor1}, disable"
          ",switch:Lid Switch, exec, hypr-lock"
        ];
      })
    ];

    # hyprland crash reports
    custom.persist = {
      home.directories = [
        ".hyprland"
      ];
    };
  };
}
