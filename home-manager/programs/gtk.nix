{
  pkgs,
  config,
  lib,
  isNixOS,
  ...
}:
let
  catppuccinDefault = "Blue";
  catppuccinAccents = {
    Blue = "#89b4fa";
    Flamingo = "#f2cdcd";
    Green = "#a6e3a1";
    Lavender = "#b4befe";
    Maroon = "#eba0ac";
    Mauve = "#cba6f7";
    Peach = "#fab387";
    Pink = "#f5c2e7";
    Red = "#f38ba8";
    # Rosewater = "#f5e0dc";
    Sapphire = "#74c7ec";
    Sky = "#89dceb";
    Teal = "#94e2d5";
    Yellow = "#f9e2af";
  };
in
{
  home = {
    pointerCursor = lib.mkIf isNixOS {
      package = pkgs.simp1e-cursors;
      name = "Simp1e-Catppuccin-Frappe";
      size = 28;
      gtk.enable = true;
      x11.enable = true;
    };

    sessionVariables = {
      XCURSOR_SIZE = config.home.pointerCursor.size;
    };
  };

  dconf.settings = {
    # disable dconf first use warning
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };
    # set dark theme for gtk 4
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.sessionVariables.GTK_THEME = "Kanagawa-BL-LB";

  home.packages = [ pkgs.gtk-engine-murrine ];

  gtk = {
    enable = true;
    theme = {
      name = "Kanagawa-BL-LB";
      package = pkgs.kanagawa-gtk-theme;
    };
    iconTheme = {
      name = "Tela circle dark";
      package = pkgs.tela-circle-icon-theme;      
    };
    font = {
      name = "${config.custom.fonts.monospace}";
      package = pkgs.nerd-fonts.gohufont;
      size = 6;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-error-bell = 0;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-error-bell = 0;
    };
  };

  # write theme accents into nix.json for rust to read
  custom.wallust.nixJson = {
    theme_accents = catppuccinAccents;
  };
}
