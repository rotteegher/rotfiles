{pkgs, ...}: {
  config = {
    programs = {
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

