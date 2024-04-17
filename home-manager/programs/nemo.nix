{
  pkgs,
  config,
  lib,
  isNixOS,
  ...
}: let
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
in {
  home = {
    packages = [
      pkgs.cinnamon.nemo-fileroller
      nemo-patched
    ];
  };

  # fix mimetype associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      {
        "inode/directory" = "nemo.desktop";
        # wtf zathura registers itself to open archives
        "application/zip" = "org.gnome.FileRoller.desktop";
        "application/vnd.rar" = "org.gnome.FileRoller.desktop";
        "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
      }
      // lib.optionalAttrs config.programs.zathura.enable {
        "application/pdf" = "org.pwmt.zathura.desktop";
      }
      // (lib.optionalAttrs config.programs.imv.enable
        {
          "image/jpeg" = "imv-dir.desktop";
          "image/gif" = "imv-dir.desktop";
          "image/webp" = "imv-dir.desktop";
          "image/png" = "imv-dir.desktop";
        });
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
    "smb://192.168.1.101/wdc-data smbLAPwdc"
    "smb://192.168.1.101/stsea-okii smbLAPstsea"
    "smb://192.168.1.101/persist smbLAPpersist"
  ];

  # other OSes seem to override this file
  xdg.configFile."mimeapps.list".force = !isNixOS;
  xdg.configFile."gtk-3.0/bookmarks".force = !isNixOS;

  dconf.settings = {
    # fix open in terminal
    "org/gnome/desktop/applications/terminal" = {
      exec = config.custom.terminal.exec;
    };
    "org/cinnamon/desktop/applications/terminal" = {
      exec = config.custom.terminal.exec;
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
    };
    "org/nemo/preferences/menu-config" = {
      selection-menu-make-link = true;
      selection-menu-copy-to = true;
      selection-menu-move-to = true;
    };
  };

  custom.persist = {
    home.directories = [
      # folder preferences such as view mode and sort order
      ".local/share/gvfs-metadata"
    ];
    # cache = [
    #   # thumbnail cache
    #   ".cache/thumbnails"
    # ];
  };
}
