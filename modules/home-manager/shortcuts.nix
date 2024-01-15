{lib, ...}: {
  options.rot.shortcuts = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {
      h = "~";
      rots = "~/pr/rotfiles";
      dots = "~/pr/dotfiles";
      cfg = "~/.config";
      vd = "~/Videos";
      vaa = "~/Videos/Anime";
      vac = "~/Videos/Anime/Current";
      vC = "~/Videos/Courses";
      vm = "~/Videos/Movies";
      vt = "~/Videos/TV";
      vtc = "~/Videos/TV/Current";
      vtn = "~/Videos/TV/New";
      pr = "~/pr";
      PC = "~/Pictures";
      Ps = "~/Pictures/Screenshots";
      Pw = "~/Pictures/Wallpapers";
      dd = "~/Downloads";
      dp = "~/Downloads/pending";
      dus = "~/Downloads/pending/Unsorted";
      mw = "/md/wdc-data";
      ms = "/md/stsea-okii";
    };
    description = "Shortcuts for navigating across multiple terminal programs.";
  };
}
