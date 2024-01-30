{
  host,
  inputs,
  lib,
  pkgs,
  user,
  ...
}: let
  rots = "/persist/home/${user}/pr/rotfiles";
  nh = inputs.nh.packages.${pkgs.system}.default;
  # outputs the current nixos generation
  nix-current-generation = pkgs.writeShellScriptBin "nix-current-generation" ''
    generations=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
    # add generation number from before desktop format
    echo $(expr $generations + ${
      if host == "desktop"
      then "1196"
      else "0"
    })
  '';
  # set the current configuration as default to boot
  ndefault = pkgs.writeShellScriptBin "ndefault" ''
    sudo /run/current-system/bin/switch-to-configuration boot
  '';
  # build flake but don't switch
  nbuild = pkgs.writeShellApplication {
    name = "nbuild";
    runtimeInputs = [nswitch];
    text = ''
      if [ "$#" -eq 0 ]; then
          nswitch --dry --hostname "${host}"
      else
          # provide hostname as the first argument
          nswitch --dry --hostname "$@"
      fi
    '';
  };
  # switch via nix flake (note you have to pass --hostname to switch to a different host)
  nswitch = pkgs.writeShellApplication {
    name = "nswitch";
    runtimeInputs = with pkgs; [git nix-current-generation nh];
    text = ''
      cd ${rots}

      # stop bothering me about untracked files
      untracked_files=$(git ls-files --exclude-standard --others .)
      if [ -n "$untracked_files" ]; then
          git add "$untracked_files"
      fi

      if [ "$#" -eq 0 ]; then
          nh os switch --nom --hostname "${host}" -- --option eval-cache false
      else
          # force host to be current host
          # disable shellcheck (substition syntax)
          # shellcheck disable=SC2001
          cleaned_args=$(echo "$@" | sed 's/\(--hostname\) [^[:space:]]*/\1 ${host}/')
          nh os switch --nom "$cleaned_args" -- --option eval-cache false
      fi

      # only relevant if --dry is passed
      if [[ "$*" == *"--dry"* ]]; then
        echo -e "Switched to Generation \033[1m$(nix-current-generation)\033[0m"
      fi
      cd - > /dev/null
    '';
  };
  # update all nvfetcher overlays and packages
  nv-update = pkgs.writeShellApplication {
    name = "nv-update";
    runtimeInputs = [nswitch pkgs.nvfetcher];
    text = ''
      cd ${rots}

      # run nvfetcher for overlays
      nvfetcher --config overlays/nvfetcher.toml --build-dir overlays

      # run nvfetcher for packages
      mapfile -t pkg_tomls < <(fd nvfetcher.toml packages)

      for pkg_toml in "''${pkg_tomls[@]}"; do
          pkg_dir=$(dirname "$pkg_toml")
          nvfetcher --config "$pkg_toml" --build-dir "$pkg_dir"
      done
      cd - > /dev/null
    '';
  };
  # update via nix flake
  upd8 = pkgs.writeShellApplication {
    name = "upd8";
    runtimeInputs = [nswitch pkgs.nvfetcher nv-update];
    text = ''
      cd ${rots}
      nix flake update
      nv-update
      nswitch "$@"
      cd - > /dev/null
    '';
  };
  # build and push config for laptop
  nswitch-remote = pkgs.writeShellApplication {
    name = "nswitch-remote";
    text = ''
      cd ${rots}
      sudo nixos-rebuild --target-host "root@''${1:-rot-laptop}" --flake ".#''${2:-omen}" switch
      cd - > /dev/null
    '';
  };
  # build iso images
  nbuild-iso = pkgs.writeShellApplication {
    name = "nbuild-iso";
    runtimeInputs = [nswitch pkgs.nixos-generators];
    text = ''
      cd ${rots}
      nix build ".#nixosConfigurations.$1.config.system.build.isoImage"
      cd - > /dev/null
    '';
  };
  json2nix = pkgs.writeShellApplication {
    name = "json2nix";
    runtimeInputs = with pkgs; [hjson alejandra];
    text = ''
      json=$(cat - | hjson -j 2> /dev/null)
      nix eval --expr "lib.fromJSON '''$json'''" | alejandra -q
    '';
  };
  yaml2nix = pkgs.writeShellApplication {
    name = "yaml2nix";
    runtimeInputs = with pkgs; [yq alejandra];
    text = ''
      yaml=$(cat - | yq)
      nix eval --expr "lib.fromJSON '''$yaml'''" | alejandra -q
    '';
  };
  # create an fhs environment to run downloaded binaries
  # https://nixos-and-flakes.thiscute.world/best-practices/run-downloaded-binaries-on-nixos
  # fhs = let
  #   base = pkgs.appimageTools.defaultFhsEnvArgs;
  # in
  #   pkgs.buildFHSUserEnv (base
  #     // {
  #       name = "fhs";
  #       targetPkgs = pkgs: (
  #         # pkgs.buildFHSUserEnv provides only a minimal FHS environment,
  #         # lacking many basic packages needed by most software.
  #         # Therefore, we need to add them manually.
  #         #
  #         # pkgs.appimageTools provides basic packages required by most software.
  #         (base.targetPkgs pkgs)
  #         ++ [
  #           pkgs.pkg-config
  #           pkgs.ncurses
  #           # Feel free to add more packages here if needed.
  #         ]
  #       );
  #       profile = "export FHS=1";
  #       runScript = "bash";
  #       extraOutputsToInstall = ["dev"];
  #     });
in {
  # execute shebangs that assume hardcoded shell paths
  services.envfs.enable = true;

  # run unpatched binaries on nixos
  programs.nix-ld.enable = true;

  environment = {
    sessionVariables.FLAKE = rots; # forr configuring nh

    systemPackages =
      # for nixlang / nixpkgs
      with pkgs;
        [
          alejandra
          nil
          nixpkgs-fmt
          nixpkgs-review
        ]
        ++ [
          comma
          nix-current-generation
          nh
          ndefault
          nbuild
          nbuild-iso
          nswitch
          nvfetcher
          nv-update
          upd8
          json2nix
          yaml2nix
          # fhs
        ]
        ++ lib.optionals (host == "desktop") [
          nswitch-remote
        ];
  };

  hm.home.shellAliases = {
    nsw = "nswitch";
  };

  # add symlink of configuration flake to nixos closure
  # https://blog.thalheim.io/2022/12/17/hacking-on-kernel-modules-in-nixos/
  # system.extraSystemBuilderCmds = ''
  #   ln -s ${self} $out/flake
  # '';

  nix = {
    # use flakes
    extraOptions = "experimental-features = nix-command flakes auto-allocate-uids";
    gc = {
      # Automatic garbage collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };
    package = pkgs.nixVersions.unstable;
    # change nix registry to use nixpkgs from flake
    # https://www.foodogsquared.one/posts/2023-11-10-speeding-up-nixos-package-search-on-the-terminal/
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nixpkgs-master = {
        from = {
          type = "indirect";
          id = "nixpkgs-master";
        };
        to = {
          type = "github";
          owner = "NixOS";
          repo = "nixpkgs";
        };
      };
    };
    settings = {
      max-jobs = 6;
      auto-optimise-store = true; # Optimise symlinks
      substituters = [
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://ghostty.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];
    };
  };
}
