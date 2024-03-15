{pkgs, ...}: {
  imports = [
    ./bash.nix
    ./btop.nix
    ./direnv.nix
    ./fish.nix
    ./git.nix
    # ./neovim.nix
    ./nix.nix
    ./rice.nix
    ./cava.nix
    ./shell.nix
    ./starship.nix
    ./tmux.nix
    ./yazi.nix
  ];

  home.packages = with pkgs; [
    dysk # better disk info
    fd
    fx
    jq
    htop
    btop
    cmus
    sd
    ugrep
    file
    b3sum
    tldr
    ent
    coreutils-full

    marksman
    vscode-langservers-extracted
    yaml-language-server
    taplo
  ];

  programs = {
    bat.enable = true;

    eza = {
      enable = true;
      enableBashIntegration = true;
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

  custom.persist = {
    home.directories = [".local/share/zoxide"];
  };
}
