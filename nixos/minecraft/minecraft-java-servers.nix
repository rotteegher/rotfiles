{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  # Host specific Module Configuration
  cfg = config.custom.services.minecraft-java-servers;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # USE mcrcon to connect to server console via rcon.password
      mcrcon
    ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      dataDir = "/srv/minecraft";
      environmentFile = cfg.environmentFile;
      servers = {
        fabric-latest = let
          cfg = config.custom.services.minecraft-java-servers.fabric-latest;
        in {
          enable = cfg.do-run;
          autoStart = cfg.autoStart;
          jvmOpts = cfg.jvmOpts;
          serverProperties = cfg.serverProperties;
          package = pkgs.fabricServers.fabric;
        };
      };
    };
  };
}
