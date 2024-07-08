{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  openOnWorkspace = workspace: program: "[workspace ${toString workspace} silent] ${program}";
in {
  # start hyprland
  custom.shell.profileExtra = lib.mkIf (config.wayland.windowManager.hyprland.enable && config.custom.hyprland.autostart) ''
    if [ "$(tty)" = "/dev/tty1" ]; then
      exec Hyprland &> /dev/null
    fi
  '';

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # init ipc listener
      "hypr-ipc &"

      # browsers
      # (openOnWorkspace 1 "brave --incognito")
      # (openOnWorkspace 1 "brave --profile-directory=Default")

      # firefox
      (openOnWorkspace 1 "librewolf")

      # Open Discord
      (openOnWorkspace 4 "discord-vesktop")

      # audio
      (openOnWorkspace 9 "pavucontrol")
      (openOnWorkspace 9 "easyeffects")

      # (openOnWorkspace 9 "easyeffects")

      # download desktop
      (openOnWorkspace 10 "$term ~/_CURRENT")
      (openOnWorkspace 10 "nemo ~/_CURRENT")
      (openOnWorkspace 10 "transmission-remote-gtk")
      # (openOnWorkspace 10 "hyprctl dispatch layoutmsg orientationcycle left top")

      # Telegram
      (openOnWorkspace 8 "telegram-desktop")

      (openOnWorkspace 3 ''nix run nixpkgs#st fish'')

      # focus the initial workspaces on startup
      "hyprctl dispatch workspace 1"
      "hyprctl dispatch workspace 4"

      "swww-daemon &"
      "sleep 1; hypr-wallpaper && launch-waybar"

      # fix gparted "cannot open display: :0" error
      "${lib.getExe pkgs.xorg.xhost} +local:${user}"
      # fix Authorization required, but no authorization pcustomocol specified error
      # "${pkgs.xorg.xhost}/bin/xhost si:localuser:root"

      # stop fucking with my cursors
      "hyprctl setcursor ${config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}"

      # start polkit agent
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &"

      # Start input engine fcitx5
      "fcitx5 &"
    ];
  };
}
