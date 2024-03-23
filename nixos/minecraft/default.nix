{
  config,
  lib,
  user,
  pkgs,
  ...
}: let
  cfg-java = config.custom-nixos.services.minecraft-java-servers;
  cfg-bedrock = config.custom-nixos.services.minecraft-bedrock-server;
in {
  imports = [
    ./minecraft-java-servers.nix
    ./minecraft-bedrock-server.nix
  ];
  config = lib.mkIf (cfg-java.enable || cfg-bedrock) {
    users.users.${user}.extraGroups = [ "minecraft" ];
    environment.systemPackages = with pkgs; [
      packwiz
    ];
    custom-nixos.persist.root.directories = [
      "/srv"
    ];
  };
}
