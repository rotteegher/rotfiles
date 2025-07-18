{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      cool-retro-term
      sl
      libcaca
      oneko
      ninvaders
      asciiquarium
      bastet
      cbonsai
      cmatrix
      hollywood
      fastfetch
      cpufetch
      fortune
      cowsay
      imagemagick
      nitch
      pipes-rs
      scope-tui
      moon-buggy
      tokei
      tenki
      snowmachine
      ninvaders
      wl-color-picker
      umoria
      inputs.wfetch.packages.${pkgs.system}.wfetch
      # custom.wl_shimeji
    ];

    shellAliases = {
      neofetch = "${lib.getExe pkgs.fastfetch} --config neofetch";
      hw = "hypr-wallpaper";
    };
  };

  custom.persist = {
    home.directories = [
      ".local/share/wl_shimeji"
    ];
  };


  # create xresources
  xresources = {
    path = "${config.xdg.configHome}/.Xresources";
    properties = {
      "Xft.dpi" = 90;
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
