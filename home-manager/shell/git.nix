{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.custom.git;
  git-reword = pkgs.writeShellApplication {
    name = "git-reword";
    text = ''
      if [ -z "$1" ];
      then
          echo "No SHA provided. Usage: \"git reword <SHA>\"";
          exit 1;
      fi;
      if [ "$(git rev-parse "$1")" == "$(git rev-parse HEAD)" ];
      then
          echo "$1 is the current commit on this branch.  Use \"git commit --amend\" to reword the current commit.";
          exit 1;
      fi;
      git merge-base --is-ancestor "$1" HEAD;
      ANCESTRY=$?;
      if [ $ANCESTRY -eq 1 ];
      then
          echo "SHA is not an ancestor of HEAD.";
          exit 1;
      elif [ $ANCESTRY -eq 0 ];
      then
          git stash;
          START=$(git rev-parse --abbrev-ref HEAD);
          git branch savepoint;
          git reset --hard "$1";
          git commit --amend;
          git rebase -p --onto "$START" "$1" savepoint;
          git checkout "$START";
          git merge savepoint;
          git branch -d savepoint;
          git stash pop;
      else
          exit 2;
      fi
    '';
  };
in {
  home.packages = [
    git-reword
    pkgs.delta
    pkgs.lazygit
  ];

  programs = {
    gh.enable = true;
    git = {
      enable = true;
      userName = "Dmytro Serdiukov";
      userEmail = "noisetide@gmail.com";
      # GPG SIGNING KEY
      signing = lib.mkIf cfg.enable {
        signByDefault = true;
        key = cfg.git-keyid;
      };
      extraConfig = {
        init = {defaultBranch = "master";};
        branch = {
          master = {merge = "refs/heads/master";};
          main = {merge = "refs/heads/main";};
        };
        core = {
          pager = "delta";
        };
        interactive = {
          diffFilter = "delta --color-only";
        };
        delta = {
          navigate = true;
          light = false;
          # side-by-side = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        format = {
          pretty = "format:%C(yellow)%h%Creset -%C(red)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset";
        };
        diff = {
          tool = "nvim -d";
          guitool = "code";
          colorMoved = "default";
        };
        pull = {rebase = true;};
        push = {default = "simple";};
      };
      aliases = {reword = "!sh git-reword";};
    };
  };

  # extra git functions
  custom.shell.packages = {
      # create a new branch and push it to origin
    gbc = ''
      git branch "$1"
      git checkout "$1"
    '';
    # delete a remote branch
    grd = ''
      git branch -D "$1"
      git push origin --delete "$1"
    '';
    # searches git history, can never remember this stupid thing
    # 2nd argument is target path and subsequent arguments are passed through
    gsearch = ''git log -S"$1" -- "\${"2:-."}" "$*"[2,-1]'';
  };

  home.shellAliases = {
    lg = "lazygit";
    gaa = "git add --all";
    gb = "git branch";
    gbtr = "git bisect reset";
    gcaam = "gaa && gcam";
    gcam = "git commit --amend";
    gco = "git checkout";
    gdc = "git diff --cached";
    gdi = "git diff";
    gl = "git pull";
    glg = "git log";
    gm = "git merge";
    gp = "git push";
    gpf = "git push --force";
    glc = ''gl origin "$(git rev-parse --abbrev-ref HEAD)"'';
    gpc = ''gp origin "$(git rev-parse --abbrev-ref HEAD)"'';
    groot = "cd $(git rev-parse - -show-toplevel)";
    grh = "git reset --hard";
    gri = "git rebase --interactive";
    gst = "git status -s -b && echo && git log | head -n 1";
    gsub = "git submodule update --init --recursive";
    # access github page for the repo we are currently in
    github = "open \`git remote -v | grep github.com | grep fetch | head -1 | awk '{print $2}' | sed 's/git:/http:/git'\`";
    # cleanup leftover files from merges
    mergeclean = "find . -type f -name '*.orig' -exec rm -f {} \;";
  };

  custom.persist = {
    home.directories = [
      ".config/gh"
      ".config/systemd"
    ];
  };
}
