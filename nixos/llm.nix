{
  config,
  lib,
  pkgs,
  user,
  ...
}:
lib.mkMerge [
    (lib.mkIf config.custom.llm.enable {
      environment.systemPackages = with pkgs; [
        ollama
        shell-gpt
        llm
      ];
      # setup port forwarding
      networking.firewall.allowedTCPPorts = [9000];
      users.users.${user}.extraGroups = ["render" "video"];

      hardware.nvidia-container-toolkit.enable = true;

      # ollama
      # docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
      virtualisation.oci-containers.backend = "docker";
      # virtualisation.oci-containers.containers = {
      #   ollama = {
      #     image = "ollama/ollama";
      #     ports = ["11434:11434"];
      #     volumes = [
      #       "ollama:/root/.ollama"
      #     ];
      #     extraOptions = [
      #       "--network=host"
      #       "--gpus=all"
      #     ];
      #     autoStart = true;
      #   };
      # };

      # open-webui
      # pc:
      #     docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
      # server:
      #     docker run -d -p 3000:8080 -e OLLAMA_BASE_URL=https://example.com -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
      # example:
      #     docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main
      # virtualisation.oci-containers.containers = {
      #   open-webui = {
      #     image = "ghcr.io/open-webui/open-webui";
      #     ports = ["3000:9000"];
      #     # dependsOn = [ "ollama" ];
      #     volumes = [
      #       "open-webui:/app/backend/data"
      #     ];
      #     environment = {
      #       OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      #       PORT = "9000";
      #     };
      #     extraOptions = [
      #       "--network=host"
      #     ];
      #     autoStart = true;
      #   };
      # };

      custom.persist = {
        home.directories = [
          ".ollama"
        ];
      };
    })
    (lib.mkIf (config.custom.sops.enable && config.custom.llm.enable) {
      sops.secrets.openai_api_key.owner = user;
    })
]


