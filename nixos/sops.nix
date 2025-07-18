{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  homeDir = config.hm.home.homeDirectory;
in
{
  options.custom = with lib; {
    sops.enable = mkEnableOption "sops" // {
      default = true;
    };
  };

  config = lib.mkIf config.custom.sops.enable {
    sops = {
      # to edit secrets file, run "sops hosts/secrets.json"
      defaultSopsFile = ../hosts/secrets.json;

      # use full path to persist as the secrets activation script runs at the start
      # of stage 2 boot before impermanence
      # gnupg.sshKeyPaths = [ ];
      age = {
        sshKeyPaths = [ "/persist${homeDir}/.ssh/id_ed25519-desk" ];
        keyFile = "/persist${homeDir}/.config/sops/age/keys.txt";
        # This will generate a new key if the key specified above does not exist
        generateKey = false;
      };
    };

    users.users.${user}.extraGroups = [ config.users.groups.keys.name ];

    # script to bootstrap a new install
    environment.systemPackages = with pkgs; [
      pkgs.sops
      (writeShellApplication {
        name = "install-remote-secrets";
        runtimeInputs = [ rsync ];
        text =
          let
            persistHome = "/persist${homeDir}";
            copy = src: ''rsync -aP --mkpath "${persistHome}/${src}" "nixos@$remote:$target/${src}"'';
          in
          ''
            read -rp "Enter ip of remote host: " remote
            target="/mnt${persistHome}"

            while true; do
                read -rp "Use /mnt? [y/n] " yn
                case $yn in
                  [Yy]*)
                    echo "y";
                    target="/mnt${persistHome}"
                    return;;
                  [Nn]*)
                    echo "n";
                    target="${persistHome}"
                    return;;
                  *)
                    echo "Please answer yes or no.";;
                esac
            done

            ${copy ".ssh/"}
            ${copy ".config/sops/age/"}
          '';
      })
    ];

    custom.persist.home = {
      directories = [ ".config/sops" ];
    };
  };
}

