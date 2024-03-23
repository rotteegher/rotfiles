{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  cfg = config.custom-nixos.services.minecraft-bedrock-server;

  cfgToString = v:
    if lib.isBool v
    then lib.boolToString v
    else toString v;

  serverPropertiesFile = pkgs.writeText "server.properties" (''
      # server.properties managed by NixOS configuration
    ''
   + lib.concatStringsSep "\n" (lib.mapAttrsToList
      (n: v: "${n}=${cfgToString v}")
      cfg.serverProperties));

  permissionsFile = pkgs.writeText "permissions.json" (lib.strings.toJSON cfg.permissions);

  serverPort = cfg.serverProperties.server-port or 25575;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # USE "sudo conspy 4" command to enter server console
      # NOTE: press ESC three times quickly to exit
      conspy

      # My bedrock server package
      custom.minecraft-bedrock-server
    ];

    # make sure the tty4 is not overrun by getty
    services.logind.extraConfig = ''
      NAutoVTs=3
    '';

    systemd.services.minecraft-bedrock-server = {
      enable = cfg.do-run;
      description = "Minecraft Bedrock Server Service";
      wantedBy = ["multi-user.target"];
      conflicts = ["getty@tty4.service"];
      after = ["network.target" "getty@tty4.service"];

      serviceConfig = {
        Type = "simple";

        ProtectHome = "read-only";
        ProtectSystem = "full";
        PrivateDevices = false;
        PrivateTmp = false;

        ReadWritePaths = cfg.dataDir;
        StateDirectory = cfg.dataDir;
        WorkingDirectory = cfg.dataDir;

        # Sockets="minecraft-bedrock-server.socket";
        StandardInput = "tty";
        # StandardInput = "socket";
        StandardOutput = "tty";
        StandardError = "journal";
        TTYPath = "/dev/tty4";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;

        Restart = "on-failure";
        RestartSec = 5;
        RemainAfterExit = true;

        ExecStart = "/bin/sh -c '${cfg.package}/bin/bedrock_server > /dev/tty4 < /dev/tty4'";
        # PLEASE ISSUE a "stop" command to the server manually
        # before shutting down systemd service
      };

      preStart = ''
        echo "Server Directory: $(stat ${cfg.dataDir})"

        echo "Setting permissions"
        chown -R ${user}:users ${cfg.dataDir}
        chmod -R gu+rwx "${cfg.dataDir}"

        echo "Starting Copying Package Files: ${cfg.package} -> ${cfg.dataDir}"
        cp -a -f ${cfg.package}/var/lib/* .

        cp -f ${serverPropertiesFile} server.properties
        echo "[server.properties] Server Properties: $(cat server.properties)"

        cp -f ${permissionsFile} permissions.json
        echo "[permissions.json] Server Permissions: $(cat permissions.json)"

        echo "Server Directory Contents: $(ls -la --group-directories-first ${cfg.dataDir})"
      '';
    };

    networking.firewall = {
      allowedUDPPorts = [serverPort 19132 19133];
      allowedTCPPorts = [serverPort 19132 19133];
    };
  };
}
