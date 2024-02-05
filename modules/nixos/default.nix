{...}: {
  imports = [
    ./hardware.nix
    ./impermanence.nix
    ./programs.nix
    ./minecraft-bedrock-server.nix
    ./minecraft-java-server.nix
  ];
}
