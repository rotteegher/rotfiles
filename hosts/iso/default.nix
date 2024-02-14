{
  inputs,
  lib,
  system,
  ...
}: let
  mkIso = nixpkgs: isoPath:
    lib.nixosSystem {
      inherit system;
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/${isoPath}.nix"
        ({pkgs, ...}: {

          nix = {
            # use flakes
            extraOptions = "experimental-features = nix-command flakes auto-allocate-uids";
            package = pkgs.nixVersions.unstable;
          };

          environment.systemPackages =
            [
              (pkgs.writeShellApplication {
                name = "rotos-install";
                runtimeInputs = [pkgs.curl];
                text = ''sh <(curl -L https://raw.githubusercontent.com/rotteegher/rotfiles/master/install.sh)'';
              })
              (pkgs.writeShellApplication {
                name = "rotos-recover";
                runtimeInputs = [pkgs.curl];
                text = ''sh <(curl -L https://raw.githubusercontent.com/rotteegher/rotfiles/master/recover.sh)'';
              })
              (pkgs.writeShellApplication {
                name = "rotos-reinstall";
                runtimeInputs = [pkgs.curl];
                text = ''sh <(curl -L https://raw.githubusercontent.com/rotteegher/rotfiles/master/recover.sh)'';
              })
            ]
            ++ (with pkgs; [
              btop
              git
              helix
              tmux
              zellij
              file
              b3sum
              ripgrep
              jq
              yazi
              dysk
              cmus
              bat
              fzf
              htop
            ]);
        })
      ];
    };
in {
  gnome-iso = mkIso inputs.nixpkgs-stable "installation-cd-graphical-calamares-gnome";
  kde-iso = mkIso inputs.nixpkgs-stable "installation-cd-graphical-calamares-plasma5";
  minimal-iso = mkIso inputs.nixpkgs-stable "installation-cd-minimal";
  gnome-iso-unstable = mkIso inputs.nixpkgs "installation-cd-graphical-calamares-gnome";
  kde-iso-unstable = mkIso inputs.nixpkgs "installation-cd-graphical-calamares-plasma5";
  minimal-iso-unstable = mkIso inputs.nixpkgs "installation-cd-minimal";
}
