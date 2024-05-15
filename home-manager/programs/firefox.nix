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
    home.packages = with pkgs; [ librewolf ];
    programs = lib.mkIf config.custom.firefox.enable {
      # firefox
      firefox = {
        enable = true;
        package = firefoxPkg;

        profiles.${user} = {
          # TODO: define keyword searches here?
          # search.engines = [ ];

          extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
            darkreader
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
        ".librewolf"
        ".cache/librewolf"
      ];
    };
  };
}
