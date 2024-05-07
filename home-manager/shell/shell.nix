# create a cross shell config
{
  config,
  lib,
  pkgs,
  ...
}: let
  pr_dir = "/persist${config.home.homeDirectory}/pr";
in {
  home = {
    shellAliases =
      {
        ":e" = "nvim";
        ":o" = "hx";
        ":q" = "exit";
        c = "clear";
        cat = "bat";
        ccat = "command cat";
        crate = "cargo";
        isodate = ''date -u +"%Y-%m-%dT%H:%M:%S-%Z"'';
        man = "${pkgs.bat-extras.batman}/bin/batman";
        mime = "xdg-mime query filetype";
        mkdir = "mkdir -p";
        mount = "mount --mkdir";
        open = "xdg-open";
        py = "python";
        l = "eza -lag --group-directories-first --git";
        lto = "eza -lag --group-directories-first --git --total-size";

        rhx = "cd ~/pr/rotfiles & hx .";
        dhx = "cd ~/pr/dotfiles & hx .";

        hy = "exec Hyprland &> /dev/null";

        # cd aliases
        ".." = "cd ..";
        "..." = "cd ../..";
      }
      //
      # add shortcuts for quick cd in shell
      lib.mapAttrs (_: value: "cd ${value}") config.custom.shortcuts;
  };

  custom.shell.packages = {
    fdnix = ''${lib.getExe pkgs.fd} "$@" /nix/store'';
    md = ''[[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1"'';
    # improved which for nix
    where = ''readlink -f "$(which "$1")"'';
    ywhere = ''yazi "$(dirname "$(dirname "$(readlink -f "$(which "$1")")")")"'';
    # server command, runs a local server
    server = ''${lib.getExe pkgs.python3} -m http.server "\${"1:-8000"}"'';
    renamer = pkgs.custom.lib.useDirenv "${pr_dir}/personal-graphql" ''cargo run --release --bin renamer'';
    openpr = ''
      cd ${pr_dir}
      if [[ $# -eq 1 ]]; then
        cd "$1";
      fi
    '';
  };

  # openpr cannot be implemented as script as it needs to change the directory of the shell
  # bash function and completion for openpr
  programs.bash.initExtra = ''
    function openpr() {
        cd ${pr_dir}
        if [[ $# -eq 1 ]]; then
          cd "$1";
        fi
    }
    _openpr() {
        ( cd ${pr_dir}; printf "%s\n" "$2"* )
    }
    complete -o nospace -C _openpr openpr
  '';

  programs.fish.functions.openpr = ''
    cd ${pr_dir}
    if test (count $argv) -eq 1
      cd $argv[1]
    end
  '';

  # fish completion
  xdg.configFile."fish/completions/openpr.fish".text = ''
    function _openpr
        find ${pr_dir} -maxdepth 1 -type d -exec basename {} \;
    end
    complete --no-files --command openpr --arguments "(_openpr)"
  '';
}
