{
  pkgs,
  user,
  lib,
  config,
  ...
}: {
  config = {
    # setup pipewire for audio
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    services.pulseaudio.enable = false;

    # services.jack = {
    #   jackd.enable = true;
    #   # support ALSA only programs via ALSA JACK PCM plugin
    #   alsa.enable = false;
    #   # support ALSA only programs via loopback device (supports programs like Steam)
    #   # loopback = {
    #   #   enable = true;
    #     # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
    #     # dmixConfig = ''
    #     #   period_size 2048
    #     # '';
    #   # };
    # };

    musnix = {
      enable = true;
      rtcqs.enable = true;
      # kernel.realtime = true;
    };
    users.users.${user} = {...}: {
      extraGroups = ["jackaudio" "audio" ];
    };

    environment.systemPackages = with pkgs; [
      sox
      alsa-lib
      alsa-utils
      pavucontrol
      helvum
      easyeffects
      pulseaudio
      qjackctl
      qpwgraph
      jack2
      vmpk # piano
    ];
  };
}
