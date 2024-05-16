{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.custom.lutris.enable {
  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraPkgs = pkgs: [
        # List package dependencies here
      ];
      extraLibraries =  pkgs: [
        # List library dependencies here
      ];
    })
  ];
  custom.persist = {
      home.directories = [
        ".local/share/lutris"
        "Games"
      ];
    };

}
