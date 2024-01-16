{
  config,
  isLaptop,
  lib,
  pkgs,
  ...
}: let
  cfg = config.rot-nixos;
in {
  options.rot-nixos = {
    ### NIXOS LEVEL OPTIONS ###
    distrobox.enable = lib.mkEnableOption "distrobox";
    docker.enable = lib.mkEnableOption "docker" // {default = cfg.distrobox.enable;};
    hyprland.enable = lib.mkEnableOption "hyprland (nixos)" // {default = true;};
    keyd.enable = lib.mkEnableOption "keyd" // {default = isLaptop;};
    syncoid.enable = lib.mkEnableOption "syncoid";
    bittorrent.enable = lib.mkEnableOption "Torrenting Applications";
    vercel.enable = lib.mkEnableOption "Vercel Backups";
    virt-manager.enable = lib.mkEnableOption "virt-manager";
    steam.enable = lib.mkEnableOption "steam";

    # MINECRAFT
    services.minecraft-bedrock-server = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If enabled, start a Minecraft Bedrock Server. The server
          data will be loaded from and saved to
          <option>services.minecraft-bedrock-server.dataDir</option>.
        '';
      };
            dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/minecraft-bedrock";
        description = ''
          Directory to store Minecraft Bedrock database and other state/data files.
        '';
      };

      serverProperties = lib.mkOption {
        type = with lib.types; attrsOf (oneOf [ bool int str ]);
        default = {
            server-name = "Dedicated Server";
            gamemode = "survival";
            difficulty = "easy";
            allow-cheats = false;
            max-players = 10;
            online-mode = false;
            white-list = false;
            server-port = 19132;
            server-portv6 = 19133;
            view-distance = 32;
            tick-distance = 4;
            player-idle-timeout = 30;
            max-threads = 8;
            level-name = "Bedrock level";
            level-seed = "";
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
        example = lib.literalExample ''
          {
            server-name = "Dedicated Server";
            gamemode = "survival";
            difficulty = "easy";
            allow-cheats = false;
            max-players = 10;
            online-mode = false;
            white-list = false;
            server-port = 19132;
            server-portv6 = 19133;
            view-distance = 32;
            tick-distance = 4;
            player-idle-timeout = 30;
            max-threads = 8;
            level-name = "Bedrock level";
            level-seed = "";
            default-player-permission-level = "member";
            texturepack-required = false;
            content-log-file-enabled = false;
            compression-threshold = 1;
            server-authoritative-movement = "server-auth";
            player-movement-score-threshold = 20;
            player-movement-distance-threshold = 0.3;
            player-movement-duration-threshold-in-ms = 500;
            correct-player-movement = false;
          }
        '';
        description = ''
          Minecraft Bedrock server properties for the server.properties file.
        '';
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.rot.minecraft-bedrock-server;
        defaultText = "pkgs.minecraft-bedrock-server";
        example = lib.literalExample "pkgs.minecraft-bedrock-server-1_17";
        description = "Version of minecraft-bedrock-server to run.";
      };
    }; # Minecraft Bedrock Server
  };
}
