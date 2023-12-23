{
  pkgs,
  user,
  config,
  lib,
  ...
}: let
  cfg = config.rot-nixos.waydroid;
  in {
    config = lib.mkIf cfg.enable {
      # environment.systemPackages = with pkgs; [ waydroid ];

      virtualisation.waydroid.enable = true;

      # persisst secrets dirs
      # rot-nixos.persist.home = {
      #   directories = [
      #     ".config/sops"
      #   ];
      # };
    };
    
  }
