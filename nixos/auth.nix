{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  autoLoginUser = config.services.displayManager.autoLogin.user;
in
  lib.mkMerge [
    # ssh settings
    {
      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.KbdInteractiveAuthentication = false;
        settings.PermitRootLogin = "prohibit-password";
        allowSFTP = true;
      };
      networking.firewall.allowedTCPPorts = [ 22 ];

      users.users = let
        keyFiles = [
          ../home-manager/id_rsa.pub
          ../home-manager/id_ed25519.pub
        ];
      in {
        root.openssh.authorizedKeys.keyFiles = keyFiles;
        ${user}.openssh.authorizedKeys.keyFiles = keyFiles;
      };
    }

    # keyring settings
    {
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.gdm.enableGnomeKeyring = autoLoginUser != null;
    }

    # misc
    {
      services.dbus.packages = [ pkgs.gcr ];
      environment.systemPackages = [
        pkgs.gcr # stops errors with copilot login?
        pkgs.pinentry-tty # stops errors for passphrase asking for gpg keys
        pkgs.pinentry-curses
      ];

      security = {
        polkit.enable = true;
        # i can't type
        sudo.extraConfig = "Defaults passwd_tries=10";
      };

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      environment.variables = {
        GNUPGHOME = "${config.hm.xdg.dataHome}/.gnupg";
      };

      services.pcscd.enable = true;
      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
        enableSSHSupport = true;
      };

      # persist keyring and misc other secrets
      custom.persist.home = {
        directories = [
          ".pki"
          ".ssh"
          ".local/share/.gnupg"
          ".local/share/keyrings"
        ];
      };
      custom.persist.root = {
        directories = [
          "/root/.pki"
          "/root/.ssh"
          "/root/.local/share/.gnupg"
          "/root/.local/share/keyrings"
        ];
      };
    }
  ]
