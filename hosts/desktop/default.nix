{
  user,
  pkgs,
  ...
}: {
  custom-nixos = {
    # hardware
    xkbLayout = "jp";
    hdds = {
      enable = true;
      stsea3tb = true;
      wdc1tb = true;
      windows = true;
    };
    nvidia.enable = true;
    zfs.encryption = false;

    bluetooth.enable = true;
    hotspot = {
      enable = true;
      internet_iface = "eno1";
      wifi_iface = "wlp4s0";
    };

    # software
    distrobox.enable = true;
    docker.enable = true;
    surrealdb.enable = true;
    # syncoid.enable = true; # TODO
    bittorrent.enable = true;
    vercel.enable = false;
    virt-manager.enable = false;
    flatpak.enable = true;
    steam.enable = true;

    services.minecraft-bedrock-server = {
      enable = true;
      do-run = true;
      package = pkgs.custom.minecraft-bedrock-server;
      dataDir = "/srv/minecraft-bedrock-server";
      permissions = [
        {
          permission = "operator";
          pfid = "6cf9edda1be490d6";
        }
        {
          permission = "operator";
          xuid = "2535460878389100";
        }
      ];
      serverProperties = {
        server-name = "Dedicated Rot Server";
        gamemode = "survival";
        difficulty = "hard";
        allow-cheats = true;
        max-players = 10;
        online-mode = true;
        white-list = false;
        server-ip = "";
        server-port = 25575;
        emit-server-telemetry = true;
        view-distance = 32;
        tick-distance = 4;
        player-idle-timeout = 30;
        max-threads = 4;
        level-name = "Jungle Island";
        level-seed = "1070141852853881206";
        default-player-permission-level = "member";
        texturepack-required = false;
        content-log-file-enabled = false;
        compression-threshold = 1;
        server-authoritative-movement = "server-auth";
        player-movement-score-threshold = 20;
        player-movement-distance-threshold = "0.3";
        player-movement-duration-threshold-in-ms = 500;
        correct-player-movement = false;
      };
    };

    services.minecraft-java-server = {
      enable = true;
      do-run = false;
      package = pkgs.papermc;
      dataDir = "/srv/minecraft-java-server";
      jvmOpts = "-Xms8192M -Xmx8192M -XX:+UseG1GC -XX:+CMSIncrementalPacing -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=4 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";
      serverProperties = {
        enable-jmx-monitoring = false;
        "rcon.port" = 25585;
        level-seed = "";
        gamemode = "survival";
        enable-command-block = false;
        enable-query = false;
        generator-settings = "{}";
        enforce-secure-profile = true;
        level-name = "Java level";
        motd = "Nixos Minecraft Server";
        "query.port" = 25565;
        pvp = true;
        generate-structures = true;
        max-chained-neighbor-updates = 1000000;
        difficulty = "easy";
        network-compression-threshold = 256;
        max-tick-time = 60000;
        require-resource-pack = false;
        use-native-transport = true;
        max-players = 20;
        online-mode = true;
        enable-status = true;
        allow-flight = false;
        initial-disabled-packs = "";
        broadcast-rcon-to-ops = true;
        view-distance = 10;
        server-ip = "";
        resource-pack-prompt = "";
        allow-nether = true;
        server-port = 25544;
        enable-rcon = false;
        sync-chunk-writes = true;
        op-permission-level = 4;
        prevent-proxy-connections = false;
        hide-online-players = false;
        resource-pack = "";
        entity-broadcast-range-percentage = 100;
        simulation-distance = 10;
        "rcon.password" = "";
        player-idle-timeout = 0;
        force-gamemode = false;
        rate-limit = 0;
        hardcore = false;
        white-list = false;
        broadcast-console-to-ops = true;
        spawn-npcs = true;
        spawn-animals = true;
        log-ips = true;
        function-permission-level = 2;
        initial-enabled-packs = "vanilla";
        level-type = "minecraft\:normal";
        text-filtering-config = "";
        spawn-monsters = true;
        enforce-whitelist = false;
        spawn-protection = 16;
        resource-pack-sha1 = "";
        max-world-size = 29999984;
      };
    };
  };

  services.xserver.displayManager.autoLogin.user = user;

  networking.hostId = "83efa833"; # required for zfs

  # open ports for devices on the local network
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source 192.168.1.0/24 -j nixos-fw-accept
  '';
  networking.firewall.allowedTCPPorts = [ 4444 ];
  networking.firewall.allowedUDPPorts = [ 4444 ];

  # networking.firewall.enable = false;
}
