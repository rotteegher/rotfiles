{
  config,
  lib,
  user,
  pkgs,
  ...
}: {
  imports = [
    ./minecraft-java-server-terrafirmagreg.nix
    ./minecraft-bedrock-server.nix
  ];
  config = lib.mkIf (config.custom.services.minecraft-bedrock-server.enable || config.custom.services.minecraft-java-servers) {
    users.users.${user}.extraGroups = ["minecraft"];
    environment.systemPackages = with pkgs; [
      packwiz
    ];
    custom.persist.root.directories = [
      "/srv"
    ];
  };
}
