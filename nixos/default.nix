{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    # hardware
    ./hdds.nix
    ./nvidia.nix
    ./zfs.nix
    ./audio.nix
    ./keyd.nix
    ./sensors.nix

    ./auth.nix
    ./samba.nix
    ./fileshare.nix
    # ./sws.nix # TODO
    ./configuration.nix
    ./wine.nix
    ./docker.nix
    ./llm.nix
    ./jellyfin.nix
    ./filezilla.nix
    ./flatpak.nix
    ./hyprland.nix
    ./impermanence.nix
    ./nix.nix
    ./plasma.nix
    ./sops.nix
    ./gh.nix
    # ./syncoid.nix
    ./transmission.nix
    ./coolify.nix
    ./users.nix
    ./surrealdb.nix
    ./minecraft
    ./steam.nix
    ./lutris.nix
    ./sleep.nix
    ./input.nix
    ./bluetooth.nix
    ./hotspot.nix
  ];

  config = {
    # automount disks
    services.gvfs.enable = true;
    # services.devmon.enable = true;
    programs.dconf.enable = true;

    environment = {
      etc = {
        # universal git settings
        "gitconfig".text = config.hm.xdg.configFile."git/config".text;
        # get gparted to use system theme
        "xdg/gtk-3.0/settings.ini".text = config.hm.xdg.configFile."gtk-3.0/settings.ini".text;
      };

      # install fish completions for fish
      # https://github.com/nix-community/home-manager/pull/2408
      pathsToLink = [ "/share/fish" ];

      variables = {
        TERMINAL = lib.getExe config.hm.custom.terminal.package;
        EDITOR = config.hm.custom.shell.defaultEditor;
        VISUAL = config.hm.custom.shell.defaultEditor;
        NIXPKGS_ALLOW_UNFREE = "1";
        STARSHIP_CONFIG = "${config.hm.xdg.configHome}/starship.toml";
      };

      # use some shell aliases from home manager
      shellAliases =
        {
          inherit (config.hm.programs.bash.shellAliases)
            eza
            ls
            ll
            la
            lla
            ;
        }
        // {
          inherit (config.hm.home.shellAliases)
            # eza related

            t
            tree
            # yazi

            y
            ;
        };

      systemPackages =
        with pkgs;
        [
          vim
          iptables-legacy
          stdmanpages
          curl
          eza
          killall
          ntfs3g
          procps
          ripgrep
          htop
          ventoy
          stress
          stress-ng
          dmidecode
          memtester
          wget
          dig
          lsof
          nmap
          arp-scan
          wireshark
          dhcpcd
          netdiscover
          aria2
          speedtest-cli
          axel
          inetutils
          usbutils
          zellij
          efibootmgr
          powertop
          powerstat
          hibernate
        ]
        ++
          # install gtk theme for root, some apps like gparted only run as root
          (with config.hm.gtk; [
            theme.package
            iconTheme.package
          ])
        # add custom user created shell packages
        ++ (lib.attrValues config.custom.shell.finalPackages)
        ++ (lib.optional config.hm.custom.helix.enable helix)
        ++ (lib.optional config.hm.custom.discord.enable vesktop);
    };

    # add custom user created shell packages to pkgs.custom.shell
    nixpkgs.overlays = [
      (_: prev: {
        custom = prev.custom // {
          shell = config.custom.shell.finalPackages // config.hm.custom.shell.finalPackages;
        };
      })
    ];

    # setup fonts
    fonts.packages = config.hm.custom.fonts.packages ++ [ pkgs.custom.rofi-themes ];

    programs = {
      # use same config as home-manager
      bash = {
        interactiveShellInit = config.hm.programs.bash.initExtra;
        loginShellInit = config.hm.programs.bash.profileExtra;
      };

      # bye bye nano
      nano.enable = lib.mkForce false;

      file-roller.enable = true;
    };

    # faster boot times
    # systemd.services.NetworkManager-wait-online.enable = false;

    # use gtk theme on qt apps
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    # fix opening terminal for nemo / thunar by using xdg-terminal-exec spec
    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = [ "${config.hm.custom.terminal.package.pname}.desktop" ];
      };
    };

    custom.persist = {
      root.directories = lib.mkIf config.hm.custom.wifi.enable [ "/etc/NetworkManager" ];

      home.directories = [ ".local/state/wireplumber" ];
    };
  };
}
