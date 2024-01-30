{
  pkgs,
  config,
  lib,
  user,
  inputs,
  ...
}: let
  firefoxPkg = pkgs.firefox-wayland;
in {
  config = {
    programs = lib.mkIf config.custom.firefox.enable {
      # firefox
      firefox = {
        enable = true;
        package = firefoxPkg;

        profiles.${user} = {
          # TODO: define keyword searches here?
          # search.engines = [ ];

          extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
            bitwarden
            darkreader
            screenshot-capture-annotate
            sponsorblock
            ublock-origin
            tab-session-manager
            # 10ten-ja-reader
          ];
        };
      };

    };

    custom.persist = {
      home.directories = [
        ".cache/mozilla"
        ".mozilla"
      ];
    };
  };
}
