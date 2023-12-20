{pkgs, config, lib, ...}: {
  config = {
    programs = lib.mkIf config.rot.firefox.enable {
      # firefox dev edition
      firefox = {
        enable = true;
        package = pkgs.firefox-wayland;
      };
    };

    rot.persist = {
      home.directories = [
        ".cache/mozilla"
        ".mozilla"
      ];
    };
  };
}

