{
  config,
  pkgs,
  lib,
  user,
  ...
}: {
config = lib.mkIf config.custom.reaper.enable {
  home = {
    packages = with pkgs; [
      # The DAW
      reaper

      # Plugins
      helm
      # sorcer
      oxefmsynth
      # fmsynth
      aether-lv2
      bespokesynth
      x42-plugins
      fluidsynth
      airwindows-lv2
      mda_lv2
      # tunefish
      soundfont-generaluser
      soundfont-ydp-grand
      noise-repellent
      speech-denoiser
      mod-distortion
      midi-trigger
      # distrho
      bshapr
      bchoppr
      fomp
      gxplugins-lv2
      fverb
      mooSpace
      boops
      # artyFX
      zam-plugins
      molot-lite
      bankstown-lv2
      # vital
    ]
    # NOTE: https://discourse.nixos.org/t/lmms-vst-plugins/42985/3
    # To add it to yabridge, we just have to add the common path for plugins:
    # $ yabridgectl add "~/.wine/drive_c/VST2"
    # Then, after we run the sync command, all plugins should be detected and loaded:
    # $ yabridgectl sync
    # If you want to know which plugins are loaded, just run the following command and it will show you the path and type for each plugin and if it’s synced or not:
    # $ yabridgectl status
    ++ [
      yabridge
      yabridgectl
    ];

    # just a NOTE: that plugins are installed into these directories:
    # `/etc/profiles/per-user/${user}/lib/lv2`
    # `/etc/profiles/per-user/${user}/lib/lxvst`

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
      DSSI_PATH = makePluginPath "dssi";
      LADSPA_PATH = makePluginPath "ladspa";
      LV2_PATH = makePluginPath "lv2";
      LXVST_PATH = makePluginPath "lxvst";
      VST_PATH = makePluginPath "vst";
      VST3_PATH = makePluginPath "vst3";
      };
    };

    custom.persist = {
      home.directories = [
        ".config/REAPER"
        ".vst"
        ".vst3"
        ".lv2"
        ".clap"
        ".local/share/yabridge"
      ];
    };
  };
}
