{pkgs, ...}: {
  imports = [
    ./bash.nix
    # ./btop.nix
    ./direnv.nix
    ./fish.nix
    ./git.nix
    # ./neovim.nix
    ./nix.nix
    ./rice
    ./shell.nix
    ./starship.nix
    ./tmux.nix
    ./yazi
  ];

  home.packages = with pkgs; [
    dysk # better disk info
    fd
    fx
    htop
    btop
    sd
    ugrep
    file
  ];

  programs = {
    bat.enable = true;

    eza = {
      enable = true;
      enableAliases = true;
      icons = true;
      extraOptions = ["--group-directories-first" "--header" "--octal-permissions"];
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    nix-index.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };

  rot.persist = {
    home.directories = [".local/share/zoxide"];
  };
}
