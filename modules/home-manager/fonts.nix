{
  lib,
  pkgs,
  ...
}: {
  options.custom = {
    fonts = {
      regular = lib.mkOption {
        type = lib.types.str;
        default = "Noto Sans Mono CJK JP";
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
          font-manager
          monocraft
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
          noto-fonts-emoji
          corefonts
          liberation_ttf
          liberation-sans-narrow
          vistafonts
          carlito
          caladea
          gelasio
          kochi-substitute
          kochi-substitute-naga10
          ipafont
          ipaexfont
          migmix
          migu
          hanazono
          ricty
          takao
          jigmo
          rictydiminished-with-firacode
          wqy_zenhei
        ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
        description = "The packages to install for the fonts";
      };
    };
  };
}
