_: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home = {
    # silence direnv
    sessionVariables.DIRENV_LOG_FORMAT = "";
  };

  custom.shell.packages = {
    mkdevenv = ''nix flake init --template github:iynaix/dotfiles#"$1"'';
  };

  custom.persist = {
    home = {
      directories = [".local/share/direnv"];
      cache = [".cache/pip"];
    };
  };
}
