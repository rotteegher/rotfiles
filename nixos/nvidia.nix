{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.custom.nvidia.enable {
    # enable nvidia support
    services.xserver.videoDrivers = [ "nvidia" ];

    boot = {
      # nvidia-uvm is required for CUDA applications
      kernelModules = [ "nvidia-uvm" ];
      # use nvidia framebuffer
      # https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers#Kernel_module_parameters for more info.
      kernelParams = [ "nvidia-drm.fbdev=1" ];
    };

    hardware = {
      nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = false;
        nvidiaSettings = false;
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };
      graphics.extraPackages = with pkgs; [
        vaapiVdpau
        nvidia-vaapi-driver
        libvdpau-va-gl

        nvtopPackages.full
        glxinfo
        vulkan-tools
      ];
    };
    environment.systemPackages = with pkgs; [
        # nvidia-vaapi-driver
        # libvdpau-va-gl
        nvtopPackages.full
        glxinfo
        vulkan-tools
        cudaPackages.cudatoolkit
        cudaPackages.cudnn
        cudaPackages.cuda_cudart
    ];

    environment.sessionVariables =
      {
        NIXOS_OZONE_WL = "1";
      }
      // lib.optionalAttrs config.programs.hyprland.enable {
        LIBVA_DRIVER_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };

    nix.settings = {
      substituters = [ "https://cuda-maintainers.cachix.org" ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
  };
}
