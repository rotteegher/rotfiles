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
  rot.shell.profileExtra = lib.mkIf (config.wayland.windowManager.hyprland.enable && config.rot.hyprland.autostart) ''
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
      # (openOnWorkspace 2 "firefox-developer-edition https://discordapp.com/channels/@me ")
      (openOnWorkspace 1 "firefox")

      # Open Discord
      (openOnWorkspace 4 "discord-vesktop")

      # audio
      (openOnWorkspace 9 "pavucontrol")
      (openOnWorkspace 9 "helvum")
      # (openOnWorkspace 9 "easyeffects")

      # download desktop
      (openOnWorkspace 10 "$term /md/wdc-data/_SMALL/_ANIME")
      (openOnWorkspace 10 "transmission-remote-gtk")
      # (openOnWorkspace 10 "hyprctl dispatch layoutmsg orientationcycle left top")

      # Telegram
      (openOnWorkspace 5 "telegram-desktop")

      # Idle
      # "${lib.getExe pkgs.swayidle} -w timeout 480 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'"

      # focus the initial workspaces on startup
      "hyprctl dispatch workspace 1"
      "hyprctl dispatch workspace 2"
      "sleep 5; hyprctl dispatch workspace 4"

      "blueman-applet"

      "sleep 1; swww init && hypr-wallpaper ~/Pictures/Wallpapers/nix-wallpaper-dracula.png"

      "sleep 5 && launch-waybar"

      # fix gparted "cannot open display: :0" error
      "${lib.getExe pkgs.xorg.xhost} +local:${user}"
      # fix Authorization required, but no authorization protocol specified error
      # "${pkgs.xorg.xhost}/bin/xhost si:localuser:root"

      # start polkit agent
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &"

      # Start input engine fcitx5
      "fcitx5"
    ];
  };
}
