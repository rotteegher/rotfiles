{pkgs, user, ...}: {
  config = {
    # setup pipewire for audio
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    hardware.pulseaudio.enable = false;

    # services.jack = {
    #   jackd.enable = true;
    #   # support ALSA only programs via ALSA JACK PCM plugin
    #   alsa.enable = false;
    #   # support ALSA only programs via loopback device (supports programs like Steam)
    #   loopback = {
    #     enable = true;
    #     # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
    #     #dmixConfig = ''
    #     #  period_size 2048
    #     #'';
    #   };

    # };
    # users.users.${user} = {...}: {
    #   extraGroups = [ "jackaudio" ];
    # };

    environment.systemPackages = with pkgs;
      [
        # alsa-lib
        # alsa-utils
        pavucontrol
        helvum
        easyeffects
      ];
  };
}
