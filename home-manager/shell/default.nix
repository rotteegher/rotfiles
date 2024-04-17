{pkgs, ...}: {
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
    jq
    sd # better sed
    libnotify
    ugrep
    file
    b3sum
    tldr
    ent
    coreutils-full

    cmus

    typora # md viewer
    marksman # mv lsp
    vscode-langservers-extracted # lldb-vscode
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
