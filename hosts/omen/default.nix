{ user, ... }:
{
  custom = {
    # xkbLayout = "us";
    nvidia.enable = true;

    bluetooth.enable = true;
    # hotspot = {
    #   enable = true;
    #   internet_iface = "eno1";
    #   wifi_iface = "wlp2s0";
    # };

    # software
    keyd.enable = true;
    wine.enable = true;
    distrobox.enable = true;
    syncoid.enable = true;
    bittorrent.enable = true;
    flatpak.enable = true;
    steam.enable = true;
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      #Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

      TLP_DEFAULT_MODE = "BAT";
      TLP_PERSISTENT_DEFAULT = 1;
    };
  };


  services.displayManager.autoLogin.user = user;

  networking.hostId = "aabb4d11"; # required for zfs

  # open ports for devices on the local network
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source 192.168.1.0/24 -j nixos-fw-accept
  '';
  networking.firewall.allowedTCPPorts = [ 4444 8080 8000 8001 3000 ];
  networking.firewall.allowedUDPPorts = [ 4444 8080 8000 8001 3000 ];

  # networking.firewall.enable = false;
}
