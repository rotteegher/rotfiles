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
          environment.systemPackages =
            [
              (pkgs.writeShellApplication {
                name = "rotos-install";
                runtimeInputs = [pkgs.curl];
                text = ''sh <(curl -L https://raw.githubusercontent.com/rotteegher/rotfiles/main/install.sh)'';
              })
              # (pkgs.writeShellApplication {
              #   name = "rotos-recover";
              #   runtimeInputs = [pkgs.curl];
              #   text = ''sh <(curl -L https://raw.githubusercontent.com/rotteegher/rotfiles/main/recover.sh)'';
              # })
              # (pkgs.writeShellApplication {
              #   name = "rotos-reinstall";
              #   runtimeInputs = [pkgs.curl];
              #   text = ''sh <(curl -L https://raw.githubusercontent.com/rotteegher/rotfiles/main/recover.sh)''; # TODO recover script
              # })
            ]
            ++ (with pkgs; [
              btop
              git
              helix
              yazi
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
