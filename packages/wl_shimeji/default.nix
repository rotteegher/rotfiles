{
  config,
  lib,
  pkgs,
  stdenv,
  source,
  ...
}:

let
  python-with-pillow = pkgs.python3.withPackages (ps: [
    ps.pillow
  ]);
in
stdenv.mkDerivation (finalAttrs:
  source // {
    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.which
      pkgs.wayland-scanner
    ];

    buildInputs = [
      pkgs.wayland
      pkgs.wayland-protocols
      python-with-pillow
      pkgs.libarchive
    ];

    makeFlags = [ "PREFIX=$(out)" ];

    installPhase = ''
      mkdir -p $out
      make install PREFIX=$out
    '';
  }
)
