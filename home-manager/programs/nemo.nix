{
  pkgs,
  config,
  lib,
  isNixOS,
  ...
}:
let
  # create a fake gnome-terminal shell script so xdg terminal applications open in the correct terminal
  # https://unix.stackexchange.com/a/642886
  fakeGnomeTerminal = pkgs.writeShellApplication {
    name = "gnome-terminal";
    text = ''${config.custom.terminal.exec} "$@"'';
  };
  nemo-patched = pkgs.cinnamon.nemo-with-extensions.overrideAttrs (_: {
    postFixup = ''
      wrapProgram $out/bin/nemo \
        --prefix PATH : "${lib.makeBinPath [ fakeGnomeTerminal ]}"
    '';
  });
in
{
  home = {
    packages = [
      pkgs.cinnamon.nemo-fileroller
      nemo-patched
    ];
  };

  # fix mimetype associations
  xdg = {
    # fix mimetype associations
    mimeApps.defaultApplications = {
      "inode/directory" = "nemo.desktop";
      # wtf zathura registers itself to open archives
      "application/zip" = "org.gnome.FileRoller.desktop";
      "application/vnd.rar" = "org.gnome.FileRoller.desktop";
      "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
    };
    # other OSes seem to override this file
    configFile = lib.mkIf (!isNixOS) {
      "mimeapps.list".force = true;
      "gtk-3.0/bookmarks".force = true;
    };
  };

  gtk.gtk3.bookmarks = [
    "file:///home/rot/Documents Documents"
    "file:///home/rot/Downloads Downloads"
    "file:///home/rot/Videos Videos"
    "file:///home/rot/Pictures Pictures"
    "file:///home/rot/Pictures/Wallpapers WALLPAPERS"
    "file:///home/rot/pr PR"
    "file:///home/rot/pr/rotfiles ROTS"
    "file:///persist PERSIST"
    "sftp://192.168.12.1 sftpLAP"
    "smb://192.168.1.101/wdc-data smbLAPwdc"
    "smb://192.168.1.101/stsea-okii smbLAPstsea"
    "smb://192.168.1.101/persist smbLAPpersist"
  ];

  dconf.settings = {
    # fix open in terminal
    "org/gnome/desktop/applications/terminal" = {
      exec = lib.getExe config.custom.terminal.package;
    };
    "org/cinnamon/desktop/applications/terminal" = {
      exec = lib.getExe config.custom.terminal.package;
    };
    "org/nemo/preferences" = {
      default-folder-viewer = "list-view";
      show-hidden-files = true;
      start-with-dual-pane = true;
      date-format-monospace = true;
      # needs to be a uint64!
      thumbnail-limit = lib.hm.gvariant.mkUint64 (100 * 1024 * 1024); # 100 mb
    };
    "org/nemo/window-state" = {
      sidebar-bookmark-breakpoint = 0;
      sidebar-width = 180;
    };
    "org/nemo/preferences/menu-config" = {
      selection-menu-make-link = true;
      selection-menu-copy-to = true;
      selection-menu-move-to = true;
    };
  };

  wayland.windowManager.hyprland.settings = {
    # disable transparency for file delete dialog
    windowrulev2 = [ "forcergbx,floating:1,class:(nemo)" ];
  };

  custom.persist = {
    home = {
      directories = [
        # folder preferences such as view mode and sort order
        ".local/share/gvfs-metadata"
      ];
      cache = [
        # thumbnail cache
        ".cache/thumbnails"
      ];
    };
  };
}
