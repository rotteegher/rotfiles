{lib, pkgs, ...}: {
    # MINECRAFT
    options.custom-nixos.services.minecraft-java-server = {
      do-run = lib.mkEnableOption "Stop minecraft server?" // { default = true;};
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If enabled, start a Minecraft Java Server. The server
          data will be loaded from and saved to
          services.minecraft-java-server.dataDir
        '';
      };
      public-port = lib.mkOption {
        type = lib.types.int;
        default = 25565;
        description = ''Self-explanatory. Port of the server that is open to public'';
      };
      jvmOpts = lib.mkOption {
        type = lib.types.str;
        default = "-Xmx2048M -Xms2048M";
        example = "-Xms4096M -Xmx4096M -XX:+UseG1GC -XX:+CMSIncrementalPacing -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";
      };
      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/srv/minecraft-java";
        description = ''
          Directory to store Minecraft Java database and other state/data files.
        '';
      };
      # Whitelisted players,
      # only has an effect when services.minecraft-server.declarative is true
      # and the whitelist is enabled via by setting serverProperties.white-list to true.
      # This is a mapping from Minecraft usernames to UUIDs. 
      # You can use https://mcuuid.net/ to get a Minecraft UUID for a username.
      whitelist = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Arbitrary whitelist for the Minecraft Java Server.";
        example = {
          username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
          username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
        };
      };

      serverProperties = lib.mkOption {
        type = with lib.types; attrsOf (oneOf [bool int str]);
        default = {
          #Minecraft server properties
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
          server-port = 25564;
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
        description = ''
          Minecraft Java server properties for the server.properties file.
        '';
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.minecraft-server;
        defaultText = "pkgs.minecraft-server";
        description = "Version of minecraft-server to run.";
      };
    }; # Minecraft Bedrock Server
}

