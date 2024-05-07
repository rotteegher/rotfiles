{
  config,
  lib,
  user,
  pkgs,
  ...
}: let
  cfg = config.custom.keyd;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.keyd
    ];
    services.keyd = {
      enable = true;
      keyboards.true = {
        ids = ["*"];
        settings.main = {
          capslock = "layer(control)";
        };
      };
    };
    users.users.${user}.extraGroups = ["keyd"];
  };
}
