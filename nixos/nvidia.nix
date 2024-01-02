{
  config,
  host,
  lib,
  pkgs,
  ...
}: let
  cfg = config.rot-nixos.nvidia;
in {
  config = lib.mkIf cfg.enable {
    # enable nvidia support
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      # prevents crashes with nvidia on resuming, see:
      # https://github.com/hyprwm/Hyprland/issues/804#issuecomment-1369994379
      powerManagement.enable = false;

      open = false;
    };

    environment = {
      systemPackages = [pkgs.nvtop pkgs.glxinfo pkgs.vulkan-tools];
      sessionVariables =
        {
          NIXOS_OZONE_WL = "1";
          WLR_NO_HARDWARE_CURSORS = "1";
          LIBVA_DRIVER_NAME = "nvidia";
          GBM_BACKEND = "nvidia-drm";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        }
        // lib.optionalAttrs (host == "vm") {
          WLR_RENDERER_ALLOW_SOFTWARE = "1";
        };
    };
  };
}
