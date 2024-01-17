{ config, lib, pkgs, ... }: 
let
  cfg = config.rot-nixos.services.minecraft-bedrock-server;

  cfgToString = v: if builtins.isBool v then lib.boolToString v else toString v;

  serverPropertiesFile = pkgs.writeText "server.properties" (''
    # server.properties managed by NixOS configuration
  '' + lib.concatStringsSep "\n" (lib.mapAttrsToList
    (n: v: "${n}=${cfgToString v}") cfg.serverProperties));

  serverPort = cfg.serverProperties.server-port or 25575;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # My bedrock server package
      rot.minecraft-bedrock-server
      # RCON DOES NOT EXIST IN BEDROCK SERVER
      mcrcon rcon rconc 
    ];

    users.groups.minecraft = {};   

    users.users.minecraft = {
      description     = "Minecraft server service user";
      home            = cfg.dataDir;
      createHome      = true;
      isSystemUser    = true;
      group = "minecraft";
    };

    systemd.services.minecraft-bedrock-server = {
      description   = "Minecraft Bedrock Server Service";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/bedrock_server";
        Restart = "always";
        User = "minecraft";
        WorkingDirectory = cfg.dataDir;
      };

      preStart = ''
        cp -a -f ${cfg.package}/var/lib/* .
        cp -f ${serverPropertiesFile} server.properties
        chmod -R guo+rwx *
      '';
    };

    networking.firewall = {
      allowedUDPPorts = [ serverPort 19132 19133 ];
      allowedTCPPorts = [ serverPort 19132 19133 ];
    };
    rot-nixos.persist = {
      root.directories = [
        "/var/lib/minecraft-bedrock"
      ];
    };
  };
}
