{
  lib,
  pkgs,
  ...
}: {
  options.rot = {
    fonts = {
      regular = lib.mkOption {
        type = lib.types.str;
        default = "Inter";
        description = "The font to use for regular text";
      };
      monospace = lib.mkOption {
        type = lib.types.str;
        # default = "JetBrainsMono Nerd Font";
        default = "Monocraft";
        description = "The font to use for monospace text";
      };
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          monocraft
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
          (nerdfonts.override {fonts = ["JetBrainsMono"];})
        ];
        description = "The packages to install for the fonts";
      };
    };
  };
}
