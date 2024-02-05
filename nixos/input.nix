{
  config,
  pkgs,
  user,
  ...
}: {
  config = {
    # Select internationalisation properties.
    i18n = {
      inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = with pkgs; [
          fcitx5-mozc
          fcitx5-anthy
          fcitx5-gtk
        ];
      };
    };
    custom-nixos.persist = {
      home.directories = [
        ".config/fcitx/"
        ".config/fcitx5/"
      ];
    };
    services.xserver.xkb = {
      layout = "jp";
      variant = "";
      # options = "japan:hztg_escape";
    };

    # KEYMAPS
    console = {
      # font = "ruscii_8x8";
      # font = "drdos8x14";
      # packages = with pkgs; [terminus_font];
      # keyMap = "jp106";

      # seems to break virtual-console service because it can't find the font
      # https://github.com/NixOS/nixpkgs/issues/257904
      # font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
      # useXkbConfig = true; # use xkb.options in tty.

    };
    services.gpm.enable = true;

    # piper
    services.ratbagd.enable = true;
    environment.systemPackages = [pkgs.piper];

    users.users.${user} = {...}: {
      extraGroups = ["input"];
    };

    environment.variables = {
      # GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      GLFW_IM_MODULE = "fcitx";
    };
  };
}
