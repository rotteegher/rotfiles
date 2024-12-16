{ user, ... }:
{
  imports = [ ./minecraft-servers.nix ];
  custom = {
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

    dns.enable = true;
    bluetooth.enable = true;
    hotspot = {
      enable = true;
      internet_iface = "eno1";
      wifi_iface = "wlp5s0";
    };


    # software
    fileshare.enable = true;
    samba.enable = true;

    wine.enable = true;
    distrobox.enable = false;
    jellyfin.enable = true;
    pr_managment.enable = true;
    nginx.enable = true;
    llm.enable = true;
    docker.enable = true;
    surrealdb.enable = true;
    # syncoid.enable = true; # TODO
    bittorrent = {
      enable = true;
      downloadDir = "/home/${user}/_CURRENT";
    };
    flatpak.enable = true;
    steam.enable = true;
    lutris.enable = true;
  };

  services.displayManager.autoLogin.user = user;

  networking.hostId = "83efa833"; # required for zfs

  # open ports for devices on the local network
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source 192.168.1.0/24 -j nixos-fw-accept
  '';
  networking.firewall.allowedTCPPorts = [ 4444 7777 77 ];
  networking.firewall.allowedUDPPorts = [ 4444 7777 77 ];

  # networking.firewall.enable = false;

  # fix clock to be compatible with windows
  time.hardwareClockInLocalTime = true;
}
