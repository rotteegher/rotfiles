{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.custom.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      gamescopeSession.enable = true;
    };
    environment.systemPackages = with pkgs; [
      steam
      gamescope
      mangohud

      # steamcmd
      # steam-tui
      gcc
      cxxtools
      libcxx
      libgcc
      openssl
      nghttp2
      rtmpdump
      libpsl
      curl
      krb5
      keyutils
      glfw-wayland-minecraft
      path-of-building
    ];
    custom.persist = {
      home.directories = [ ".local/share/Steam" ".config/mangohud" ".config/unity3d" ];
    };
  };
}
