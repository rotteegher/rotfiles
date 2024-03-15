{
  config,
  lib,
  pkgs,
  ...
}: lib.mkIf config.custom-nixos.llm.enable {
  environment.systemPackages = with pkgs; [
    ollama
  ];
  # setup port forwarding
  networking.firewall.allowedTCPPorts = [8080];

  custom-nixos.persist = {
    home.directories = [
      ".ollama"
    ];
  };
}
