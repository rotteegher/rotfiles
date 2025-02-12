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
    ./minecraft-java-server-fabricer.nix
  ];
  config = lib.mkIf (config.custom.minecraft.enable) {
    users.users.${user}.extraGroups = ["minecraft"];
    environment.systemPackages = with pkgs; [
      packwiz
    ];
    custom.persist.root.directories = [
      "/srv"
    ];
    custom.persist.home.directories = [
      ".gradle"
    ];
  };
}
