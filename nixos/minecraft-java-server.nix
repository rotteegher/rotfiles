{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  # Host specific Module Configuration
  cfg = config.custom-nixos.services.minecraft-java-server;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # USE mcrcon to connect to server console via rcon.password
      mcrcon

      # java server package
      # minecraft-server
    ];

    # use NixOS module to declare your Minecraft
    services.minecraft-server = {
      enable = cfg.do-run;
      eula = true;
      openFirewall = true;
      declarative = true;
      package = cfg.package;

      serverProperties = cfg.serverProperties;

      dataDir = cfg.dataDir;
      jvmOpts = cfg.jvmOpts;
    };

    # Change some settings to the systemd service
    # systemd.services.minecraft-server = {
    #   after = ["network.target"];

      # preStart = ''
      #   echo "Server Directory: $(stat ${cfg.dataDir})"
      #   echo "Server Directory Contents: $(ls -la --group-directories-first ${cfg.dataDir})"
      # '';

      # don't start Minecraft server on system startup
      # wantedBy = pkgs.lib.mkForce [];

      # start on system startup
      # wantedBy = ["multi-user.target"];
    # };

    custom-nixos.persist = {
      root.directories = [
        # default dir is /srv/minecraft-java
        cfg.dataDir
      ];
    };
  };
}

