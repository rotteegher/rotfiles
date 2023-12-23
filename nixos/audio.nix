{pkgs, ...}: {
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

    environment.systemPackages = with pkgs;
      [
        alsa-lib
        pavucontrol
        helvum
        easyeffects
        lyrebird
        sox
      ];
  };
}
