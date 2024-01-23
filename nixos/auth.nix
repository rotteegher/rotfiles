{
  config,
  lib,
  pkgs,
  user,
  host,
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

  services.xserver.displayManager.autoLogin.user = lib.mkDefault (
    if config.boot.zfs.requestEncryptionCredentials
    then user
    else null
  );
  services.getty.autologinUser = autoLoginUser;
  # systemd.services."getty@tty2".enable = false;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
    };
  };

  security = {
    pam.services.gdm.enableGnomeKeyring = autoLoginUser != null;
    polkit.enable = true;
    # Reboot/poweroff for unprivileged users
    # Grants permissions to reboot/poweroff the machine to users in the users group.
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("users")
            && (
              action.id == "org.freedesktop.login1.reboot" ||
              action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
              action.id == "org.freedesktop.login1.power-off" ||
              action.id == "org.freedesktop.login1.power-off-multiple-sessions"
            )
          )
        {
          return polkit.Result.YES;
        }
      })
    '';
  };

  environment.systemPackages = [
    # stops errors with copilor login?
    pkgs.gcr
    # auth agent
    pkgs.polkit-kde-agent
  ];

  # AUTH agent
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-kde-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit-kde-agent}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

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
