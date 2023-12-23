{
config,
pkgs,
lib,
...
}: {
  config = lib.mkIf config.rot.discord.enable  {
    home.packages = [ pkgs.discord ];

    # rot.persist = {
    #   home.directories = [
    #     ".config/discord"
    #   ];
    # };
  };
}

