{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.custom.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      gamescopeSession.enable = true;
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
    # environment.variables = # DOESN'T WORK
    # let
    #   additionalPackages = with pkgs; [
    #     libcxx
    #     libcxxrt
    #     libunwind
    #   ];
    # in
    # {
    #   LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath additionalPackages}:$LD_LIBRARY_PATH";
    # };
    environment.systemPackages = with pkgs; let
      libunwind-relinked = pkgs.libunwind.overrideAttrs (oldAttrs: rec{
        name = "libunwind-relinked";
        postInstall = oldAttrs.postInstall + ''
          cp $out/lib/libunwind.so $out/lib/libunwind.so.1
        '';
      });
    in [
      steam
      steamcmd
      gamescope
      mangohud

      (pkgs.makeDesktopItem {
        name = "steam-minimal-runtime";
        exec = "${pkgs.lib.getExe pkgs.steam} -cef-disable-gpu-compositing -cef-disable-gpu steam://open/minigameslist %U";
        desktopName = "Steam Minimal (Runtime)";
        icon = "${pkgs.steam}/share/icons/hicolor/16x16/apps/steam.png";
      })
      (pkgs.writeShellApplication {
        name = "steam-minimal-runtime";
        text = ''
            ${pkgs.lib.getExe pkgs.steam} -cef-disable-gpu-compositing -cef-disable-gpu steam://open/minigameslist %U
        '';
      })

      # steamcmd
      # steam-tui
      gcc
      cxxtools
      libcxx
      libcxxrt
      libunwind-relinked
      libgcc
      openssl
      nghttp2
      rtmpdump
      libpsl
      curl
      krb5
      keyutils
      glfw-wayland-minecraft
      # path-of-building
      ckan
    ];
    # fileSystems."/md/wckan" = {
    #   device = "wdc-blue/ckan";
    #   fsType = "zfs";
    #   neededForBoot = false;
    #   options = ["defaults" "mode=777"];
    # };
    # fileSystems."/md/zckan" = {
    #   device = "/dev/zvol/zroot/ckan";
    #   fsType = "ext4";
    #   neededForBoot = false;
    #   options = ["defaults"];
    # };
    fileSystems."/md/ramdisk" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["defaults" "size=48G" "mode=777"];
      neededForBoot = false;
    };

    custom.persist = {
      home.directories = [ ".local/share/Steam" ".config/mangohud" ".config/unity3d" ".steam" ];
    };
  };
}
