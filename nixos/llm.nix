{
  config,
  lib,
  pkgs,
  user,
  ...
}:
lib.mkIf config.custom.llm.enable {
  environment.systemPackages = with pkgs; [
    ollama
    ollama-cuda
    # shell-gpt
    # llm
    aichat
  ];
  # setup port forwarding
  networking.firewall.allowedTCPPorts = [8080 9000];
  users.users.${user}.extraGroups = ["render" "video" "ollama"];

  hardware.nvidia-container-toolkit.enable = true;

  # ollama
  # docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
  virtualisation.oci-containers.backend = "docker";

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    group = "root";
    package = pkgs.ollama-cuda;
    port = 11434;
    home = "/var/lib/private/ollama";
    openFirewall = true;
    environmentVariables = {
      CUDA_PATH = "${pkgs.cudatoolkit}";
      STATE_DIRECTORY = "/var/lib/private/ollama";
      OLLAMA_STATE_DIRECTORY = "/var/lib/private/ollama";
    };
  };

  services.open-webui = {
    enable = true;
    openFirewall = true;
    stateDir = "/var/lib/private/open-webui";
    host = "0.0.0.0";
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      # Disable authentication
      WEBUI_AUTH = "False";
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      LOCAL_FILES_ONLY = "False";
      USER_AGENT = "${user}";
    };
  };

  # open-webui
  # pc:
  #     docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
  # server:
  #     docker run -d -p 3000:8080 -e OLLAMA_BASE_URL=https://example.com -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
  # example:
  #     docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main

  custom.persist = {
    home.directories = [
      ".ollama"
      ".config/aichat"
    ];
    root.directories = [
      # "/var/lib/ollama"
      "/var/lib/private/ollama"
      "/var/lib/private/open-webui"
    ];
  };
}


