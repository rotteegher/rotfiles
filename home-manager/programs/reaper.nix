{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.custom.reaper.enable {
    home = {
      packages = with pkgs; [ 
        reaper 
        helm

        oxefmsynth
        aether-lv2
        bespokesynth
      ];
      # persist plugins
      # sessionVariables = {
      #   LV2_PATH = "~/.nix-profile/lib/lv2/:~/.lv2:/nix/var/nix/profiles/default/lib/lv2:/var/run/current-system/sw/lib/lv2";
      #   VST_PATH = "~/.nix-profile/lib/vst/:~/.vst:/nix/var/nix/profiles/default/lib/vst:/var/run/current-system/sw/lib/vst";
      #   LXVST_PATH = "~/.nix-profile/lib/lxvst/:~/.lxvst:/nix/var/nix/profiles/default/lib/lxvst:/var/run/current-system/sw/lib/lxvst";
      #   LADSPA_PATH = "~/.nix-profile/lib/ladspa/:~/.ladspa:/nix/var/nix/profiles/default/lib/ladspa:/var/run/current-system/sw/lib/ladspa";
      #   DSSI_PATH = "~/.nix-profile/lib/dssi/:~/.dssi:/nix/var/nix/profiles/default/lib/dssi:/var/run/current-system/sw/lib/dssi";
      # };
      sessionVariables = let
        makePluginPath = format:
          (lib.makeSearchPath format [
            "$HOME/.nix-profile/lib"
            "/run/current-system/sw/lib"
            "/etc/profiles/per-user/$USER/lib"
          ])
          + ":$HOME/.${format}";
      in {
        DSSI_PATH   = makePluginPath "dssi";
        LADSPA_PATH = makePluginPath "ladspa";
        LV2_PATH    = makePluginPath "lv2";
        LXVST_PATH  = makePluginPath "lxvst";
        VST_PATH    = makePluginPath "vst";
        VST3_PATH   = makePluginPath "vst3";
      };
    };
    custom.persist = {
      home.directories = [
        ".config/REAPER"
      ];
    };
  };
}
