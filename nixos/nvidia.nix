{
  config,
  host,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.nvidia;
in
{
  config = lib.mkIf cfg.enable {
    # enable nvidia support
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
    };

    environment = {
      systemPackages = with pkgs; [
        nvtopPackages.full
        glxinfo
        vulkan-tools
        cudaPackages.cudatoolkit
        cudaPackages.cudnn
        cudaPackages.cuda_cudart
      ];
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        WLR_NO_HARDWARE_CURSORS = "1";
        LIBVA_DRIVER_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      } // lib.optionalAttrs (host == "vm") { WLR_RENDERER_ALLOW_SOFTWARE = "1"; };
    };
    custom.persist = {
      home.directories = [ ".config/nvtop" ];
    };
  };
}
