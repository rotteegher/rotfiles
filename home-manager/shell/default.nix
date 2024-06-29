{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./btop.nix
    ./cava.nix
    ./direnv.nix
    ./eza.nix
    ./fish.nix
    ./git.nix
    # ./neovim.nix
    ./nix.nix
    ./rice.nix
    ./rust.nix # TODO
    ./shell.nix
    ./starship.nix
    ./tmux.nix
    # ./typescript.nix # TODO
    ./yazi.nix
  ];

  home.packages = with pkgs; [
    dysk # better disk info
    fd # better find
    fx # terminal json viewer and processor
    htop
    dust # better du
    jq
    sd # better sed
    libnotify
    ugrep
    file
    b3sum
    tldr
    hwatch
    ent
    busybox
    coreutils-full
    ffmpeg

    cmus

    typora # md viewer
    marksman # mv lsp
    vscode-langservers-extracted # lldb-vscode
    javascript-typescript-langserver # web js
    nodePackages.typescript-language-server
    yaml-language-server # yaml lsp
    taplo # toml lsp
  ];

  programs = {
    bat.enable = true;

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
    home.directories = [
      ".local/share/zoxide"
      ".config/Typora"
    ];
  };
}
