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
      wl-color-picker
      inputs.wfetch.packages.${pkgs.system}.wfetch
    ];

    shellAliases = {
      neofetch = "${lib.getExe pkgs.fastfetch} --config neofetch";
      hw = "hypr-wallpaper";
    };
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
