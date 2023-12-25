
{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  openOnWorkspace = workspace: program: "[workspace ${toString workspace} silent] ${program}";
in {
  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    # start hyprland
    rot.shell.profileExtra = ''
      # if [ "$(tty)" = "/dev/tty1" ]; then
        # exec Hyprland &> /dev/null
      # fi
    '';

    wayland.windowManager.hyprland.settings = {
      exec-once = [
        # init ipc listener
        # "hypr-ipc &"

        "/nix/store/$(ls -la /nix/store | rg polkit-kde-agent | grep '^d' | awk '{print $9}')/libexec/polkit-kde-authentication-agent-1 & "

        # browsers
        # (openOnWorkspace 1 "brave --incognito")
        # (openOnWorkspace 1 "brave --profile-directory=Default")


        # firefox
        # (openOnWorkspace 2 "firefox-developer-edition https://discordapp.com/channels/@me ")
        (openOnWorkspace 2 "firefox")

        # file manager
        (openOnWorkspace 4 "nemo")

        # terminal
        (openOnWorkspace 1 "$term")

        # audio
        (openOnWorkspace 9 "pavucontrol")
        (openOnWorkspace 9 "helvum")
        # (openOnWorkspace 9 "easyeffects")

        # download desktop
        (openOnWorkspace 10 "$term /md/wdc-data/_SMALL/_ANIME")
        (openOnWorkspace 10 "transmission-remote-gtk")

        # Telegram
        (openOnWorkspace 5 "telegram-desktop")
        # "${pkgs.swayidle}/bin/swayidle -w timeout 480 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'"

        # focus the initial workspaces on startup
        # "hyprctl dispatch workspace 9"
        # "hyprctl dispatch workspace 7"
        "hyprctl dispatch workspace 1"

        # FIXME: weird race condition with swww init, need to sleep for a second
        # https://github.com/Horus645/swww/issues/144
        # "sleep 1; swww init && hypr-wallpaper"

        # "sleep 5 && launch-waybar"

        # fix gparted "cannot open display: :0" error
        "${pkgs.xorg.xhost}/bin/xhost +local:${user}"
        # fix Authorization required, but no authorization protocol specified error
        # "${pkgs.xorg.xhost}/bin/xhost si:localuser:root"

        # Input fcitx5
        "fcitx5"
      ];
    };
  };
}
