{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./audio.nix
    ./auth.nix
    ./configuration.nix
    ./keyd.nix
    ./docker.nix
    ./llm.nix
    ./filezilla.nix
    ./flatpak.nix
    ./hdds.nix
    ./hyprland.nix
    ./impermanence.nix
    ./nix.nix
    ./nvidia.nix
    ./plasma.nix
    # ./syncoid.nix
    ./transmission.nix
    ./users.nix
    # ./vercel.nix
    ./surrealdb.nix
    ./minecraft
    ./virt-manager.nix
    ./steam.nix
    ./zfs.nix
    ./sleep.nix
    ./input.nix
    ./bluetooth.nix
    ./hotspot.nix
  ];

  config = {
    # automount disks
    services.gvfs.enable = true;
    # services.devmon.enable = true;

    environment = {
      etc = {
        # git
        "gitconfig".text = config.hm.xdg.configFile."git/config".text;
      };
      variables = {
        TERMINAL = config.hm.custom.terminal.exec;
        EDITOR = "hx";
        VISUAL = "hx";
        NIXPKGS_ALLOW_UNFREE = "1";
        STARSHIP_CONFIG = "${config.hm.xdg.configHome}/starship.toml";
      };

      systemPackages = with pkgs;
        [
          stdmanpages
          curl
          eza
          killall
          ntfs3g
          procps
          ripgrep
          htop
          wget
          dig
          lsof
          nmap
          arp-scan
          wireshark
          netdiscover
          aria2
          inetutils
          usbutils
          zellij
          efibootmgr
          powertop
          powerstat
        ]
        ++
          # install gtk theme for root, some apps like gparted only run as root
          (with config.hm.gtk; [
            theme.package
            iconTheme.package
          ])
        # add custom user created shell packages
        ++ (lib.attrValues config.custom-nixos.shell.finalPackages)
        ++ (lib.optional config.hm.custom.helix.enable helix)
        ++ (lib.optional config.hm.custom.discord.enable vesktop);
    };

    # add custom user created shell packages to pkgs.custom.shell
    nixpkgs.overlays = [
      (_: prev: {
        custom = prev.custom // {
          shell = config.custom-nixos.shell.finalPackages // config.hm.custom.shell.finalPackages;
        };
      })
    ];


    # setup fonts
    fonts.packages = config.hm.custom.fonts.packages;

    # set up programs to use same config as home-manager
    programs.bash = {
      interactiveShellInit = config.hm.programs.bash.initExtra;
      loginShellInit = config.hm.programs.bash.profileExtra;
    };

    # bye bye nano
    programs.nano.enable = lib.mkForce false;

    programs.file-roller.enable = true;

    # use gtk theme on qt apps
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    custom-nixos.persist = {
      root.directories = lib.mkIf config.hm.custom.wifi.enable [
        "/etc/NetworkManager"
      ];

      home.directories = [
        ".local/state/wireplumber"
      ];
    };
  };
}
