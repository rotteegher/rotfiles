{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.custom.k3b.enable {
    home.packages = [pkgs.k3b];
  };
}
