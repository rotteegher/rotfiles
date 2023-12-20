{
config,
pkgs,
lib,
...
}: {
  config = lib.mkIf config.rot.k3b.enable  {
    home.packages = [ pkgs.k3b ];
  };
}
