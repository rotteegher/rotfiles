{
  config,
  lib,
  pkgs,
  user,
  std,
  ...
}: let
  # Host specific Module Configuration
  cfg = config.custom.services.minecraft-java-servers.terrafirmagreg;

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

  tfcConfigFile = pkgs.writeText "tfc-common.toml" (''
      # tfc config file managed by NixOS configuration
    '' + "\n" + cfg.tfcConfigFile);

  opsJsonFile = pkgs.writeText "ops.json" ('' 
    # ops.json managed by NixOS configuration
  '' + "\n" + builtins.toJSON cfg.opsJson);
  
  serverPort = cfg.serverProperties.server-port or 25565;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # USE mcrcon or rcon to connect to server console via rcon.password
      mcrcon
      rcon

      # my server modpack package
      pkgs.custom.terrafirmagreg
    ];

    # ensure data persistence
    custom.persist.root.directories = [cfg.dataDir];
    
    systemd.services.minecraft-java-server-terrafirmagreg = {
      enable = cfg.do-run;
      description = "Minecraft Java Server Service";
      wantedBy = ["multi-user.target"];
      # conflicts = ["getty@tty3.service"];
      after = ["network.target"];

      path = [ pkgs.jdk17_headless ];
      serviceConfig = {
        Type = "simple";

        # ProtectHome = "read-only";
        PrivateDevices = false;
        PrivateTmp = false;

        ReadWritePaths = cfg.dataDir;
        StateDirectory = cfg.dataDir;
        WorkingDirectory = cfg.dataDir;

        # StandardInput = "tty";
        # StandardOutput = "tty";
        # TTYPath = "/dev/tty3";
        # TTYReset = true;
        # TTYVHangup = true;
        # TTYVTDisallocate = true;

        Restart = "on-failure";
        RestartSec = 5;
        RemainAfterExit = true;
      
        ExecStart = "${pkgs.jdk21_headless}/bin/java -jar ./minecraft_server.jar ${cfg.jvmOpts}";
      };
      preStop = "${pkgs.rcon}/bin/rcon -m -H localhost -p ${toString cfg.serverProperties."rcon.port"} -P ${cfg.serverProperties."rcon.password"} stop";
      preStart = ''
        echo "Server Directory $(stat ${cfg.dataDir})"

        cp -r ${cfg.package}/* .

        cp -f ${serverPropertiesFile} server.properties
        echo "[server.properties] Server Properties: $(cat server.properties)"

        cp -f ${opsJsonFile} ops.json
        echo "[ops.json] Server Operators: $(cat ops.json)"

        cp -f ${tfcConfigFile} config/tfc-common.toml
        echo "[tfc-common.toml] TFC CONFIG: $(cat config/tfc-common.toml)"

        echo "Setting permissions"
        chown -R ${user}:users ${cfg.dataDir}
        chmod -R gu+rwx "${cfg.dataDir}"

        echo "Server Directory Contents: $(ls -la --group-directories-first ${cfg.dataDir})"
      '';
    };

    networking.firewall = {
      allowedUDPPorts = [serverPort 19132 19133 25585 cfg.serverProperties."rcon.port"];
      allowedTCPPorts = [serverPort 19132 19133 25585 cfg.serverProperties."rcon.port"];
    };

    # services.minecraft-servers = {
    #   enable = true;
    #   eula = true;
    #   openFirewall = true;
    #   dataDir = "/srv/minecraft";
    #   environmentFile = cfg.environmentFile;
    #   servers = {
    #     terrafirmagreg = let
    #       cfg = config.custom.services.minecraft-java-servers.terrafirmagreg;
    #     in {
    #       enable = cfg.do-run;
    #       autoStart = cfg.autoStart;
    #       jvmOpts = cfg.jvmOpts;
    #       serverProperties = cfg.serverProperties;
    #       package = pkgs.fabricServers.fabric;
    #       symlinks = {
    #         "mods" = "${modpack}/mods";
    #       };
    #     };
    #   };
    # };
  };
}
