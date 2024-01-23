{
  config,
  lib,
  ...
}: {
  options.rot.git = {
    enable = lib.mkEnableOption "git-keyid";
    git-keyid = lib.mkOption {
      type = lib.types.str;
      default = "SET_KEYID_PLS";
      description = "The gpg keyid format long used for git signingkey setting";
    };
  };
}
