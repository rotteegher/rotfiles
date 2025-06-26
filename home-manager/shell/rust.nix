{
  config,
  user,
  ...
}: {
  # use centralized cargo cache
  home.sessionVariables = {
    CARGO_HOME = "/persist/cache/${config.xdg.dataHome}/.cargo";
    RUSTUP_HOME = "/persist/cache/${config.xdg.dataHome}/.rustup";
    # CARGO_TARGET_DIR = "/persist/cache/home/${user}/cargo/target";
  };

  # setup helix for rust
  programs.helix.languages.language = [
    {
      name = "rust";
      auto-format = true;
      scope = "source.rs";
      file-types = ["rs"];
      indent = {
        tab-width = 4;
        unit = "    ";
      };
      language-id = "rust";
      roots = ["Cargo.lock" "Cargo.toml"];
      language-servers = ["rust-analyzer"];
    }
  ];

  custom.shell.packages = {
    # cargo will be provided via the nix-shell
    crb = ''
      # if no arguments
      if [ $# -eq 0 ]; then
        cargo run --bin "$(basename "$(pwd)")";
      else
        cargo run --bin "$1" -- "''${@:2}";
      fi;
    '';
    crrb = ''
      # if no arguments
      if [ $# -eq 0 ]; then
        cargo run --release --bin "$(basename "$(pwd)")";
      else
        cargo run --release --bin "$1" -- "''${@:2}";
      fi;
    '';
  };

  custom.persist = {
    home = {
      cache = [
        ".cargo"
        ".local/share/.cargo"
      ];
    };
  };
}
