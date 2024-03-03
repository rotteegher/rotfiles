{
  inputs,
  pkgs,
  lib,
  ...
}: let
  # include generated sources from nvfetcher
  sources = import ./generated.nix {
    inherit (pkgs)
      fetchFromGitHub
      fetchurl
      fetchgit
      dockerTools
      ;
    };
in 
{
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
        custom =
          (prev.custom or {})
          // (import ../packages {
            inherit (prev) pkgs;
            inherit inputs;
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


        rclip = prev.rclip.overridePythonAttrs (o: {
          version = "1.7.24";

          src = prev.fetchFromGitHub {
            owner = "yurijmikhalevich";
            repo = "rclip";
            rev = "v1.7.24";
            hash = "sha256-JWtKgvSP7oaPg19vWnnCDfm7P5Uew+v9yuvH7y2eHHM=";
          };

          nativeBuildInputs = o.nativeBuildInputs ++ [pkgs.python3Packages.pythonRelaxDepsHook];

          pythonRelaxDeps = ["torch" "torchvision"];
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

        # use latest commmit from git
        waybar =
          let
            # Derived from subprojects/cava.wrap
            libcava = rec {
              version = "0.10.1";
              src = pkgs.fetchFromGitHub {
                owner = "LukashonakV";
                repo = "cava";
                rev = version;
                hash = "sha256-iIYKvpOWafPJB5XhDOSIW9Mb4I3A4pcgIIPQdQYEqUw=";
              };
            };
          in
          assert (lib.assertMsg (prev.waybar.version == "0.9.24") "waybar: use waybar from nixpkgs?");
          prev.waybar.overrideAttrs (
            o:
            sources.waybar
            // {
              version = "${o.version}-${sources.waybar.version}";
              mesonFlags = lib.remove "-Dgtk-layer-shell=enabled" o.mesonFlags;
              postUnpack = ''
                pushd "$sourceRoot"
                cp -R --no-preserve=mode,ownership ${libcava.src} subprojects/cava-${libcava.version}
                patchShebangs .
                popd
              '';
            }
          );
        # TODO: remove on new wezterm release
        # fix wezterm crashing instantly
        # https://github.com/wez/wezterm/issues/4483
        wezterm = overrideRustPackage "wezterm";
      }
    )
  ];
}
