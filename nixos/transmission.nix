{
  pkgs,
  user,
  lib,
  config,
  ...
}:
let
  home = "/home/${user}";
  downloadDir = config.custom.bittorrent.downloadDir;
in
{
  config = lib.mkIf config.custom.bittorrent.enable {
    services.transmission = {
      enable = true;
      inherit user home;
      group = "users";
      settings = {
        alt-speed-down = 50;
        alt-speed-enabled = false;
        alt-speed-time-begin = 540;
        alt-speed-time-day = 127;
        alt-speed-time-enabled = false;
        alt-speed-time-end = 1020;
        alt-speed-up = 1000;
        bind-address-ipv4 = "0.0.0.0";
        bind-address-ipv6 = "::";
        blocklist-enabled = false;
        cache-size-mb = 4;
        compact-view = false;
        details-window-height = 525;
        details-window-width = 700;
        dht-enabled = true;
        download-dir = downloadDir;
        download-queue-enabled = true;
        download-queue-size = 3;
        encryption = 1;
        idle-seeding-limit = 0;
        idle-seeding-limit-enabled = true;
        incomplete-dir = downloadDir;
        incomplete-dir-enabled = false;
        inhibit-desktop-hibernation = false;
        lpd-enabled = false;
        message-level = 1;
        open-dialog-dir = home;
        peer-congestion-algorithm = "";
        peer-id-ttl-hours = 6;
        peer-limit-global = 200;
        peer-limit-per-torrent = 50;
        peer-port = 51413;
        peer-port-random-high = 65535;
        peer-port-random-low = 49152;
        peer-port-random-on-start = false;
        peer-socket-tos = "default";
        pex-enabled = true;
        port-forwarding-enabled = true;
        preallocation = 1;
        prefetch-enabled = true;
        queue-stalled-enabled = true;
        queue-stalled-minutes = 30;
        ratio-limit = 0.1;
        ratio-limit-enabled = true;
        recent-download-dir-1 = downloadDir;
        rename-partial-files = true;
        rpc-authentication-required = false;
        rpc-bind-address = "0.0.0.0";
        rpc-enabled = true;
        rpc-host-whitelist = "";
        rpc-host-whitelist-enabled = true;
        rpc-password = "{de6b0bebaa67b3a3b4f657633598cfd765d0f09a9/fP1YP.";
        rpc-port = 9091;
        rpc-url = "/transmission/";
        rpc-username = "rot";
        rpc-whitelist = "127.0.0.1,192.168.12.1,192.168.12.22,192.168.1.101,192.168.1.104,192.168.1.105";
        rpc-whitelist-enabled = true;
        scrape-paused-torrents-enabled = true;
        script-torrent-done-enabled = false;
        script-torrent-done-filename = null;
        seed-queue-enabled = false;
        seed-queue-size = 10;
        show-backup-trackers = false;
        show-extra-peer-details = true;
        show-filterbar = true;
        show-notification-area-icon = false;
        show-options-window = true;
        show-statusbar = true;
        show-toolbar = true;
        show-tracker-scrapes = false;
        sort-mode = "sort-by-queue";
        sort-reversed = false;
        speed-limit-down = 100;
        speed-limit-down-enabled = false;
        speed-limit-up = 100;
        speed-limit-up-enabled = true;
        start-added-torrents = true;
        statusbar-stats = "total-transfer";
        torrent-added-notification-enabled = true;
        torrent-complete-notification-enabled = true;
        torrent-complete-sound-enabled = true;
        trash-can-enabled = true;
        trash-original-torrent-files = true;
        umask = 18;
        upload-slots-per-torrent = 14;
        user-has-given-informed-consent = true;
        utp-enabled = true;
        watch-dir = downloadDir;
        watch-dir-enabled = false;
      };
    };

    systemd.tmpfiles.rules = [ "d ${downloadDir} 755 ${user} users - " ];

    # setup port forwarding
    networking.firewall.allowedTCPPorts = [
      51413
      9091
    ];

    # xdg handler for magnet links
    hm = {
      xdg = {
        desktopEntries.transmission = {
          name = "Transmission";
          genericName = "BitTorrent Client";
          icon = "transmission";
          exec = "transmission-remote -a %U";
        };

        mimeApps.defaultApplications = {
          "x-scheme-handler/magnet" = "transmission.desktop";
        };
      };
    };


    hm.home.packages = with pkgs; [ transmission-remote-gtk ];

    custom.persist.home.directories = [
      "_CURRENT"
      ".config/liferea"
      ".config/transmission-daemon"
      ".config/transmission-remote-gtk"
    ];
  };
}
