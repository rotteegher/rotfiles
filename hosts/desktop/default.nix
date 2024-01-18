{user, pkgs, ...}: {
  rot-nixos = {
    # hardware
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
      wifi_iface = "wlp2s0";
    };

    # software
    distrobox.enable = true;
    syncoid.enable = true;
    bittorrent.enable = true;
    vercel.enable = false; # was true at iynaix config
    virt-manager.enable = true;
    flatpak.enable = true;
    steam.enable = true;

    services.minecraft-bedrock-server = {
      enable = true;
      package = pkgs.rot.minecraft-bedrock-server;
      serverProperties = {
            server-name = "Dedicated Rot Server";
            gamemode = "survival";
            difficulty = "hard";
            allow-cheats = false;
            max-players = 10;
            online-mode = true;
            white-list = false;
            # server-ip = "localhost";
            server-port = 25575;
            server-portv6 = 19177;
            emit-server-telemetry = true;
            # view-distance = 32;
            # tick-distance = 4;
            # player-idle-timeout = 30;
            # max-threads = 4;
            # level-name = "Bedrock level";
            # level-seed = "";
            # default-player-permission-level = "member";
            # texturepack-required = false;
            # content-log-file-enabled = false;
            # compression-threshold = 1;
            # server-authoritative-movement = "server-auth";
            # player-movement-score-threshold = 20;
            # player-movement-distance-threshold = "0.3";
            # player-movement-duration-threshold-in-ms = 500;
            # correct-player-movement = false;
      };
    };
  };

  services.xserver.displayManager.autoLogin.user = user;

  networking.hostId = "83efa833"; # required for zfs

  # open ports for devices on the local network
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source 192.168.1.0/24 -j nixos-fw-accept
  '';
  # networking.firewall.allowedTCPPorts = [ 4444 ];
  # networking.firewall.allowedUDPPorts = [ 4444 ];
}
