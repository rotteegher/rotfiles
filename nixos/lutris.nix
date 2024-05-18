{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.custom.lutris.enable {
  virtualisation.waydroid.enable = true;
  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraPkgs = _pkgs: [
        # List package dependencies here
      ];
      extraLibraries = _pkgs: [
        # List library dependencies here
      ];
    })
  ];
  custom.persist = {
    root.directories = [
      "/var/lib/waydroid"
    ];
    home.directories = [
      ".local/share/lutris"
      ".local/share/waydroid"
      "Games"
    ];
  };
}
