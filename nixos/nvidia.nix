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
      kernelParams = [ 
        "nvidia-drm.fbdev=1" "nvidia-drm.modeset=1"
        "i915.force_probe=3e92"
        "i915.modeset=1"
        "i915.enable_gvt=1"
        "i915.enable_dpcd_backlight=1"
        "psi=1"
       ];
    };

    hardware = {
      nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = true;
        nvidiaSettings = false;
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };
      graphics.extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        vaapi-intel-hybrid
        libvdpau-va-gl
        intel-vaapi-driver
        intel-media-driver
        intel-compute-runtime
        vpl-gpu-rt
        ocl-icd
        intel-ocl
        nvidia-vaapi-driver

        vulkan-loader
        vulkan-headers
        vulkan-extension-layer
        vulkan-memory-allocator
        vulkan-validation-layers
        vulkan-utility-libraries
        xorg.libXi xorg.libXmu freeglut
        xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib 
        linuxPackages.nvidia_x11
        libGLU libGL
        linuxHeaders
        libdrm
        libgbinder

        mesa
        # swiftshader
        egl-wayland
      ];
    };
    environment.systemPackages = with pkgs; [
        mesa

        nvtopPackages.full
        glxinfo
        clinfo
        inxi
        drm_info
        vulkan-tools

        vulkan-loader
        vulkan-headers
        vulkan-extension-layer
        vulkan-memory-allocator
        vulkan-validation-layers
        vulkan-utility-libraries

        cudaPackages.cudatoolkit
        cudaPackages.cudnn
        cudaPackages.cuda_cudart

        linuxHeaders
        libdrm
        libgbinder
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
