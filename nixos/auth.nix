{
  config,
  lib,
  pkgs,
  user,
  ...  
}: let
autoLoginUser = config.services.xserver.displayManager.autoLogin.user;
in {
  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  # SSH KEYS
  users.users = let
    keyFiles = [
      ../home-manager/id_ed25519.pub
    ];
    in {
    root.openssh.authorizedKeys.keyFiles = keyFiles;
    ${user}.openssh.authorizedKeys.keyFiles = keyFiles;
  };
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;

  # stops errors with copilor login?
  environment.systemPackages = [pkgs.gcr];

  services.xserver.displayManager.autoLogin.user = lib.mkDefault (
    if config.boot.zfs.requestEncryptionCredentials
    then user
    else null
  );
  services.getty.autologinUser = autoLoginUser;
  security.pam.services.gdm.enableGnomeKeyring = autoLoginUser != null;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      
    };
  };

  # i can't type xD
  security.sudo.extraConfig = "Defaults passwd_tries=10";

  # persist keyring and misc other secrets
  rot-nixos.persist.home = {
    directories = [
      ".gnupg"
      ".pki"
      ".ssh"
      ".local/share/keyrings"
    ];
  };
}
