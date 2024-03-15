{
  config,
  lib,
  pkgs,
  user,
  ...
}: lib.mkIf config.custom-nixos.llm.enable {
  environment.systemPackages = with pkgs; [
    ollama
  ];
  # setup port forwarding
  networking.firewall.allowedTCPPorts = [8080];
  users.users.${user}.extraGroups = ["render" "video"];

  custom-nixos.persist = {
    home.directories = [
      ".ollama"
    ];
  };
}
