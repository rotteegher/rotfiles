# create a cross shell config
{
  config,
  host,
  lib,
  pkgs,
  ...
}: {
  home.shellAliases =
    {
      ":e" = "nvim";
      ":o" = "hx";
      ":q" = "exit";
      c = "clear";
      cat = "bat";
      crate = "cargo";
      btop = "btop --preset 0";
      isodate = ''date -u +"%Y-%m-%dT%H:%M:%S-%Z"'';
      man = "${pkgs.bat-extras.batman}/bin/batman";
      mkdir = "mkdir -p";
      mount = "mount --mkdir";
      nano = "nvim";
      open = "xdg-open";
      opr = "openpr";
      rhx = "cd ~/pr/rotfiles & hx .";
      dhx = "cd ~/pr/dotfiles & hx .";
      py = "python";
      tr = "eza --tree --level=3";
      l = "eza -lag --group-directories-first --git";
      lto = "eza -lag --group-directories-first --git --total-size";
      v = "nvim";
      wget = "wget --content-disposition";
      coinfc = "pr coinfc";

      hy = "Hyprland";

      # cd aliases
      ".." = "cd ..";
      "..." = "cd ../..";
    }
    //
    # add shortcuts for quick cd in shell
    lib.mapAttrs (_: value: "cd ${value}") config.custom.shortcuts;

  custom.shell.functions = {
    fdnix = {
      bashBody = ''fd "$@" /nix/store'';
      fishBody = ''fd $argv /nix/store'';
    };
    md = {
      bashBody = ''[[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1"'';
      fishBody = ''if test (count $argv) -eq 1; and mkdir -p -- $argv[1]; and cd -- $argv[1]; end'';
    };
    # create a new devenv environment
    mkdevenv = {
      bashBody = ''nix flake init --template github:rotteegher/rotfiles#$1'';
      fishBody = ''nix flake init --template github:rotteegher/rotfiles#$argv[1]'';
    };
    # improved which for nix
    where = {
      bashBody = ''readlink -f $(which $1)'';
      fishBody = ''readlink -f (which $argv[1])'';
    };
    ywhere = {
      bashBody = ''yazi $(dirname $(dirname $(readlink -f $(which $1))))'';
      fishBody = ''yazi (dirname (dirname (readlink -f (which $argv[1]))))'';
    };
    # server command, runs a local server
    server = {
      bashBody = ''${pkgs.python3}/bin/python -m http.server ''${1:-8000}'';
      fishBody = ''
        if test -n "$1"
          ${pkgs.python3}/bin/python -m http.server "$1"
        else
          ${pkgs.python3}/bin/python -m http.server 8000
        end
      '';
    };
    # cd to project dir
    openpr = {
      bashBody = ''
        cd $HOME/pr
        if [[ $# -eq 1 ]]; then
          cd $1;
        fi
      '';
      bashCompletion = ''
        _openpr() {
            ( cd "$HOME/pr"; printf "%s\n" "$2"* )
        }
        complete -o nospace -C _openpr openpr
      '';
      fishBody = ''
        cd $HOME/pr
        if test (count $argv) -eq 1
          cd $argv[1]
        end
      '';
      fishCompletion = ''find "$HOME/pr" -maxdepth 1 -type d -exec basename {} \;'';
    };
    renamer = {
      bashBody = ''
        cd $HOME/pr/personal-graphql
        # activate direnv
        direnv allow && eval "$(direnv export bash)"
        cargo run --release --bin renamer
        cd - > /dev/null
      '';
      fishBody = ''
        cd $HOME/pr/personal-graphql
        # activate direnv
        direnv allow; and eval (direnv export fish)
        cargo run --release --bin renamer
        cd - > /dev/null
      '';
    };
    # utility for creating a nix repl
    nrepl = {
      bashBody = ''
        if [[ -f repl.nix ]]; then
          nix repl --arg host '"${host}"' --file ./repl.nix "$@"
        else
          nix repl "$@"
        fi
      '';
      fishBody = ''
        if test -f repl.nix
          nix repl --arg host '"${host}"' --file ./repl.nix $argv
        else
          nix repl $argv
        end
      '';
    };
  };
}
