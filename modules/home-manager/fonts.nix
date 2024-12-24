{
  lib,
  pkgs,
  ...
}: {
  options.custom = {
    fonts = {
      regular = lib.mkOption {
        type = lib.types.str;
        default = "Unifont";
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
          noto-fonts-cjk-sans
          noto-fonts-emoji
        ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
        description = "The packages to install for the fonts";
      };
    };
  };
}
