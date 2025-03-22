{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.custom.monero.enable {
    environment.systemPackages = [
      pkgs.monero-cli
    ];

    services.monero = {
      enable = true;
      dataDir = "/md/stsea-okii/_XMR";
      mining = {
        enable = false;
        threads = 2;
        address = "49WjRAbRYvcSyREQ9ZRDsUgLA3SDRD8hBHnd7KU3d3SbRnmmvZTBtbg22W7khw1m2r5NWC9Bbf4nAQFnHbL4mP8ALEppwNf";
      };
    };
  };
}
