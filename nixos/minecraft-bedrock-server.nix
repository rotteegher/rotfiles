{ config, lib, pkgs, user, ... }: 
let
  cfg = config.rot-nixos.services.minecraft-bedrock-server;

  cfgToString = v: if builtins.isBool v then lib.boolToString v else toString v;

  serverPropertiesFile = pkgs.writeText "server.properties" (''
    # server.properties managed by NixOS configuration
  '' + lib.concatStringsSep "\n" (lib.mapAttrsToList
    (n: v: "${n}=${cfgToString v}") cfg.serverProperties));

  permissionsFile = pkgs.writeText "permissions.json" (builtins.toJSON cfg.permissions);

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
        alias lss="ls -la --group-directories-first"

        echo "Server Directory: $(stat ${cfg.dataDir})"
        echo "Setting permissions"
        chown -R minecraft:minecraft "${cfg.dataDir}"
        chmod -R guo+rwx "${cfg.dataDir}"

        echo "Starting Copying Package Files: ${cfg.package} -> ${cfg.dataDir}"
        cp -a -f ${cfg.package}/var/lib/* .

        cp -f ${serverPropertiesFile} server.properties
        echo "[server.properties] Server Properties: $(cat server.properties)"

        cp -f ${permissionsFile} permissions.json
        echo "[permissions.json] Server Permissions: $(cat permissions.json)"

        echo "Server Directory Contents: $(lss ${cfg.dataDir})"
      '';
    };

    networking.firewall = {
      allowedUDPPorts = [ serverPort 19132 19133 ];
      allowedTCPPorts = [ serverPort 19132 19133 ];
    };
    rot-nixos.persist = {
      root.directories = [
        # default dir is /var/lib/minecraft-bedrock
        cfg.dataDir
      ];
    };
  };
}
