{
config,
pkgs,
user,
...
}: {
  config = {
    # Select internationalisation properties.
    i18n = {
      defaultLocale = "en_US.UTF-8";
      inputMethod = {
        enabled = "fcitx5";
          fcitx5.addons = with pkgs; [
            fcitx5-mozc
            fcitx5-anthy
            fcitx5-gtk
        ];
      };
    };
    rot-nixos.persist = {
      home.directories = [
        ".config/fcitx/"
        ".config/fcitx5/"
        ];
    };

    # KEYMAPS
    console = {
      # font = "ruscii_8x8";
      font = "drdos8x14";
      packages = with pkgs; [ terminus_font ];
      keyMap = "jp106";
      # useXkbConfig = true; # use xkbOptions in tty.

    };
    services.gpm.enable = true;

    users.users.${user} = {...}: {
      extraGroups = [ "input" ];
    };

    environment.variables = {
      # GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      GLFW_IM_MODULE = "fcitx";
    };
  };
}
