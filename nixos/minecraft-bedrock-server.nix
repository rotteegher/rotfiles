{ config, lib, pkgs, ... }: 
let
  cfg = config.rot-nixos.services.minecraft-bedrock-server;

  cfgToString = v: if builtins.isBool v then lib.boolToString v else toString v;

  serverPropertiesFile = pkgs.writeText "server.properties" (''
    # server.properties managed by NixOS configuration
  '' + lib.concatStringsSep "\n" (lib.mapAttrsToList
    (n: v: "${n}=${cfgToString v}") cfg.serverProperties));

  defaultServerPort = 19132;

  serverPort = cfg.serverProperties.server-port or defaultServerPort;
in
{
  config = lib.mkIf cfg.enable {
    users.groups.minecraft = {};   

    users.users.minecraft = {
      description     = "Minecraft server service user";
      home            = cfg.dataDir;
      createHome      = true;
      # uid             = 1337;
      isSystemUser    = true;
      group = "minecraft";
    };

  #   systemd.services.minecraft-bedrock-server = {
  #     description   = "Minecraft Bedrock Server Service";
  #     wantedBy      = [ "multi-user.target" ];
  #     after         = [ "network.target" ];

  #     serviceConfig = {
  #       ExecStart = "${cfg.package}/bin/bedrock_server";
  #       Restart = "always";
  #       User = "minecraft";
  #       WorkingDirectory = cfg.dataDir;
  #     };

  #     preStart = ''
  #       cp -a -n ${cfg.package}/var/lib/* .
  #       cp -f ${serverPropertiesFile} server.properties
  #       chmod +w server.properties
  #     '';
  #   };

  #   networking.firewall = {
  #     allowedUDPPorts = [ serverPort ];
  #   };
  };
}
