{
  inputs,
  pkgs,
  lib,
  ...
}: let
  # include generated sources from nvfetcher
  sources = import ./generated.nix {inherit (pkgs) fetchFromGitHub fetchurl fetchgit dockerTools;};
in {
  nixpkgs.overlays = [
    (
      final: prev: let
        overrideRustPackage = pkgname:
          prev.${pkgname}.overrideAttrs (o:
            sources.${pkgname}
            // {
              # creating an overlay for buildRustPackage overlay
              # https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/3
              cargoDeps = prev.rustPlatform.importCargoLock {
                lockFile = sources.${pkgname}.src + "/Cargo.lock";
                allowBuiltinFetchGit = true;
              };
            });
      in {
        # include custom packages
        rot =
          (prev.rot or {})
          // (import ../packages {
            inherit (prev) pkgs;
            inherit inputs;
          });

        # fix fish shell autocomplete error for zfs
        # https://github.com/NixOS/nixpkgs/issues/247290
        fish = prev.fish.overrideAttrs (o: {
          patches =
            (o.patches or [])
            ++ [
              (pkgs.fetchpatch {
                name = "fix-zfs-completion.path";
                url = "https://github.com/fish-shell/fish-shell/commit/85504ca694ae099f023ae0febb363238d9c64e8d.patch";
                sha256 = "sha256-lA0M7E/Z0NjuvppC7GZA5rWdL7c+5l+3SF5yUe7nEz8=";
              })
            ];

          checkPhase = "";
        });

        # patch imv to not repeat keypresses causing waybar to launch infinitely
        # https://github.com/eXeC64/imv/issues/207#issuecomment-604076888
        imv = prev.imv.overrideAttrs (o: {
          patches =
            (o.patches or [])
             ++ [
              # https://lists.sr.ht/~exec64/imv-devel/patches/39476
              ./imv-fix-repeated-keypresses.patch
            ];
        });

        # add default font to silence null font errors
        lsix = prev.lsix.overrideAttrs (o: {
          postFixup = ''
            substituteInPlace $out/bin/lsix \
              --replace '#fontfamily=Mincho' 'fontfamily="JetBrainsMono-NF-Regular"'
            ${o.postFixup}
          '';
        });

        # use latest commmit from git
        swww = overrideRustPackage "swww";

        # transmission dark mode, the default theme is hideous
        transmission = let
          themeSrc = sources.transmission-web-soft-theme.src;
        in
          prev.transmission.overrideAttrs (o: {
            # sed command taken from original install.sh script
            postInstall = ''
              ${o.postInstall}
              cp -RT ${themeSrc}/web/ $out/share/transmission/web/
              sed -i '21i\\t\t<link href="./style/transmission/soft-theme.min.css" type="text/css" rel="stylesheet" />\n\t\t<link href="style/transmission/soft-dark-theme.min.css" type="text/css" rel="stylesheet" />\n' $out/share/transmission/web/index.html;
            '';
          });

        # use dev branch
        # wallust = overrideRustPackage "wallust";

        # use latest commmit from git
        # waybar = prev.waybar.overrideAttrs (o:
        #   sources.waybar
        #   // {
        #     version = "${o.version}-${sources.waybar.version}";
        #   });
        waybar = let
          version = "3.5.1";
          catch2_3 = assert (lib.assertMsg (prev.catch2_3.version != version) "catch2: override is no longer needed");
            prev.catch2_3.overrideAttrs (_: {
              inherit version;
              src = prev.fetchFromGitHub {
                owner = "catchorg";
                repo = "Catch2";
                rev = "v${version}";
                hash = "sha256-OyYNUfnu6h1+MfCF8O+awQ4Usad0qrdCtdZhYgOY+Vw=";
              };
            });
        in
          (prev.waybar.override {inherit catch2_3;}).overrideAttrs (o:
            sources.waybar
            // {
              version = "${o.version}-${sources.waybar.version}";
            });


        # goo-engine = prev.blender.overrideAttrs (o: sources.goo-engine);
        # goo-engine = stdenv.mkDerivation (
        #   sources.goo-engine {
        #     python = pkgs.python310;

        #     phases = ["unpackPhase" "buildPhase" "installPhase"];
        #     enableParallelBuilding = true;
        #     nativeBuildInputs = with pkgs; [cmake git python pkg-config];
        #     buildInputs = with pkgs; [
        #       libjpeg libpng zstd freetype openimageio2 opencolorio openexr_3
        #       embree boost ffmpeg_5 tbb fftw libGL libGLU glew
        #       xorg.libX11 xorg.libXi xorg.libXxf86vm xorg.libXrender
        #       # Python packages
        #       python310Packages.numpy python310Packages.requests
        #     ];

        #     pythonPath = with pkgs.python310Packages; [numpy requests zstd python];

        #     postPatch = ''
        #       rm build_files/cmake/Modules/FindPython.cmake
        #     '';

        #     cmakeFlags = [
        #       "-DWITH_TBB=ON"
        #       "-DWITH_ALEMBIC=ON"
        #       "-DWITH_MOD_OCEANSIM=ON"
        #       "-DWITH_FFTW3=ON"
        #       "-DWITH_INSTALL_PORTABLE=OFF"
        #       # Python
        #       # "-DPYTHON_LIBRARY=${python.libPrefix}"
        #       # "-DPYTHON_VERSION=${python.pythonVersion}"
        #       # "-DPYTHON_LIBPATH=${python}/lib"
        #       "-DWITH_PYTHON_MODULE=OFF"
        #       "-DWITH_PYTHON_INSTALL_NUMPY=OFF"
        #       "-DWITH_PYTHON_INSTALL_ZSTANDARD=OFF"
        #       "-DWITH_PYTHON_SAFETY=ON"
        #       # OpenGL
        #       "-DWITH_GL_EGL=ON"
        #       "-DWITH_GLEW_ES=ON"
        #       ];


        #     installPhase = ''
        #       echo "########################################"
        #       echo $pythonPath
        #     '';
        #   }
        # );


        # TODO: remove on new wezterm release
        # fix wezterm crashing instantly
        # https://github.com/wez/wezterm/issues/4483
        wezterm = overrideRustPackage "wezterm";
      }
    )
  ];
}
