{
  config,
  lib,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      cbonsai
      cmatrix
      fastfetch
      imagemagick
      nitch
      pipes-rs
    ];

    shellAliases = {
      neofetch = "${lib.getExe pkgs.fastfetch} --config neofetch";
    };
  };

  # create xresources
  xresources = {
    path = "${config.xdg.configHome}/.Xresources";
    properties = {
      "Xft.dpi" = 96;
      "Xft.antialias" = true;
      "Xft.hinting" = true;
      "Xft.rgba" = "rgb";
      "Xft.autohint" = false;
      "Xft.hintstyle" = "hintslight";
      "Xft.lcdfilter" = "lcddefault";

      "*.font" = "JetBrainsMono Nerd Font Mono:Medium:size=12";
      "*.bold_font" = "JetBrainsMono Nerd Font Mono:Bold:size=12";
    };
  };
}

