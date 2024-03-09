{
  config,
  lib,
  pkgs,
  ...
}: 
lib.mkIf config.custom-nixos.surrealdb.enable {
  environment.systemPackages = [pkgs.surrealdb pkgs.insomnia];

  services.surrealdb = {
    enable = true;
    dbPath = "file:///var/lib/surrealdb/";
    extraFlags = [
      "--auth"
      "--allow-all"
      "--user" "root"
      "--pass" "root"
      "--log" "debug"
    ];
    package = pkgs.surrealdb;
  };
    
  custom-nixos.persist = {
    root.directories = [ "/var/lib/surrealdb" ];
  };
}
