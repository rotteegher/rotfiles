{
  lib,
  installShellFiles,
  rustPlatform,
  waifufetch ? false,
}:
rustPlatform.buildRustPackage {
  pname = "dotfiles-utils";
  version = "0.1.0";

  src = ./.;

  cargoLock.lockFile = ../../Cargo.lock;

  # only build waifufetch
  cargoBuildFlags = lib.optionals waifufetch ["--bin" "waifufetch"];

  # https://nixos.org/manual/nixpkgs/stable/#compiling-rust-applications-with-cargo
  # see section "Importing a cargo lock file"
  postPatch = ''
    ln -s ${../../Cargo.lock} Cargo.lock
  '';

  # create files for shell autocomplete
  nativeBuildInputs = [installShellFiles];

  preFixup =
    if waifufetch
    then ''
      installShellCompletion $releaseDir/build/dotfiles_utils-*/out/waifufetch.{bash,fish}
    ''
    else ''
      installShellCompletion $releaseDir/build/dotfiles_utils-*/out/*.{bash,fish}
    '';

  meta = with lib;
    {
      description = "Utilities for iynaix's dotfiles";
      homepage = "https://github.com/iynaix/dotfiles";
      license = licenses.mit;
      maintainers = [maintainers.iynaix];
    }
    // lib.optionalAttrs waifufetch {
      mainProgram = "waifufetch";
    };
}
