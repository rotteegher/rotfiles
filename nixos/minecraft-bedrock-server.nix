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
      tmux
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
      group           = "minecraft";
    };


    systemd.tmpfiles.rules = [
       "d ${cfg.dataDir} - minecraft minecraft"
    ];

    systemd.sockets.minecraft-bedrock-server = {
      bindsTo = ["minecraft-bedrock-server.service"];
      socketConfig = {
        ListenFIFO = "${cfg.dataDir}/systemd.stdin";
        Service = "minecraft-bedrock-server.service";
        SocketUser = "minecraft";
        SocketGroup = "minecraft";
        RemoveOnStop = true;
        SocketMode = "0600";
      };
    };

    systemd.services.minecraft-bedrock-server = {
      description   = "Minecraft Bedrock Server Service";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "network.target" ];

      serviceConfig = {
        Restart = "always";
        User = "minecraft";
        Group = "minecraft";
        # Type = "forking";
        Nice = 5;

        Sockets="minecraft-bedrock-server.socket";
        StandardInput = "socket";
        StandardOutput = "journal";
        TimeoutStopSec = 90;

        ProtectHome = "read-only";
        # ProtectSystem = "full";
        PrivateDevices = "no";
        PrivateTmp = "no";
        ReadWritePaths = cfg.dataDir;

        WorkingDirectory = cfg.dataDir;

        ExecStart = ''
            /bin/sh -c "${cfg.package}/bin/bedrock_server"
          '';
        ExecStop = ''
          /bin/sh -c "echo stop > systemd.stdin"
        '';

        KillSignal = "SIGCONT";
      };

      preStart = ''
        echo "Server Directory: $(stat ${cfg.dataDir})"

        echo "Setting permissions"
        chown -R minecraft:minecraft "${cfg.dataDir}"
        chmod -R gu+rw "${cfg.dataDir}"

        echo "Starting Copying Package Files: ${cfg.package} -> ${cfg.dataDir}"
        cp -a -f ${cfg.package}/var/lib/* .

        cp -f ${serverPropertiesFile} server.properties
        echo "[server.properties] Server Properties: $(cat server.properties)"

        cp -f ${permissionsFile} permissions.json
        echo "[permissions.json] Server Permissions: $(cat permissions.json)"

        echo "Setting permissions AGAIN"
        chown -R minecraft:minecraft "${cfg.dataDir}"
        chmod -R guo+rw "${cfg.dataDir}"
        echo "Server Directory Contents: $(ls -la --group-directories-first ${cfg.dataDir})"
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
