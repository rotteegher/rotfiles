{
  pkgs,
  user,
  lib,
  config,
  ...
}: {
  config = {
    environment.systemPackages = with pkgs; [
      lm_sensors
    ];
  };
}

