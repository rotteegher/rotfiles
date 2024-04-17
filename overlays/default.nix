{
  inputs,
  lib,
  pkgs,
  ...
}:
let
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
    (_: prev: {
      # include custom packages
      custom =
        (prev.custom or { })
        // {
          lib = pkgs.callPackage ./lib.nix { inherit (prev) pkgs; };
        }
        // (import ../packages {
          inherit (prev) pkgs;
          inherit inputs;
        });

      # nixos-small logo looks like ass
      fastfetch = prev.fastfetch.overrideAttrs (o: {
        patches = (o.patches or [ ]) ++ [ ./fastfetch-nixos-old-small.patch ];
      });

      hyprcursor =
        # assert (
        #   lib.assertMsg (prev.hyprcursor.version == "0.1.5") "hyprcursor: source overlay still needed?"
        # );
        prev.hyprcursor.overrideAttrs (
          o: sources.hyprcursor // { buildInputs = (o.buildInputs or [ ]) ++ [ prev.tomlplusplus ]; }
        );

      hyprlock = prev.hyprlock.overrideAttrs (_: sources.hyprlock);

      # add default font to silence null font errors
      lsix = prev.lsix.overrideAttrs (o: {
        postFixup = ''
          substituteInPlace $out/bin/lsix \
            --replace '#fontfamily=Mincho' 'fontfamily="JetBrainsMono-NF-Regular"'
          ${o.postFixup}
        '';
      });

      # nixos-small logo looks like ass
      neofetch = prev.neofetch.overrideAttrs (o: {
        patches = (o.patches or [ ]) ++ [ ./neofetch-nixos-small.patch ];
      });

      # fix nix package count for nitch
      nitch = prev.nitch.overrideAttrs (o: {
        patches = (o.patches or [ ]) ++ [ ./nitch-nix-pkgs-count.patch ];
      });

      # use latest commmit from git
      swww = prev.swww.overrideAttrs (
        _:
        sources.swww
        // {
          # creating an overlay for buildRustPackage overlay
          # https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/3
          cargoDeps = prev.rustPlatform.importCargoLock {
            lockFile = sources.swww.src + "/Cargo.lock";
            allowBuiltinFetchGit = true;
          };
        }
      );

      wallust =
        assert (lib.assertMsg (prev.wallust.version == "2.10.0") "wallust: use wallust from nixpkgs?");
        prev.wallust.overrideAttrs (
          o:
          sources.wallust
          // {
            nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++ [ prev.installShellFiles ];

            postInstall = ''
              installManPage man/wallust*
              installShellCompletion --cmd wallust \
                --bash completions/wallust.bash \
                --zsh completions/_wallust \
                --fish completions/wallust.fish
            '';

            # creating an overlay for buildRustPackage overlay
            # https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/3
            cargoDeps = prev.rustPlatform.importCargoLock {
              lockFile = sources.wallust.src + "/Cargo.lock";
              allowBuiltinFetchGit = true;
            };
          }
        );

    })
    inputs.nix-minecraft.overlay
  ];
}
