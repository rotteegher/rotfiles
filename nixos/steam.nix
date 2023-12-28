{
config,
pkgs,
lib,
...
}: {
  config = lib.mkIf config.rot-nixos.steam.enable  {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  
    rot-nixos.persist = {
      home.directories = [
        ".steam"
        ".local/share/Steam"
      ];
    };
  };
}


