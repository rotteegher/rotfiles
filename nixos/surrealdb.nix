{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.custom.surrealdb.enable {
  environment.systemPackages = [pkgs.surrealdb];

  services.surrealdb = {
    enable = false;
    dbPath = "file:///var/lib/private/surrealdb";
    extraFlags = [
      "--auth"
      "--allow-all"
      "--user"
      "rotter"
      "--pass"
      "rotter"
      "--log"
      "debug"
    ];
    package = pkgs.surrealdb;
  };

  custom.persist = {
    root.directories = ["/var/lib/private/surrealdb"];
  };
}
