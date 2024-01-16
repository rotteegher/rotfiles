{
  lib,
  stdenvNoCC,
  nerdfonts,
  source,
}:
stdenvNoCC.mkDerivation (source
  // {

    pname = "rofi-themes";
    version = "0a55e154598466edb4352013798acc1d2f245306";
    src = fetchFromGitHub {
      owner = "adi1090x";
      repo = "rofi";
      rev = "0a55e154598466edb4352013798acc1d2f245306";
      fetchSubmodules = false;
      sha256 = "sha256-YjyrxappcLDoh3++mtZqCyxQV2qeoNhhUy2XGwlyTng=";
    };
    date = "2023-12-14";

    buildInputs = [(nerdfonts.override {fonts = ["JetBrainsMono" "Iosevka" "Monocraft"];})];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/files
      cp -r $src/files $out
      mkdir -p $out/share/fonts/truetype
      cp $src/fonts/Icomoon-Feather.ttf $out/share/fonts/truetype/feather.ttf

      runHook postInstall
    '';

    meta = with lib; {
      description = "A huge collection of Rofi based custom Applets, Launchers & Powermenus";
      homepage = "https://github.com/adi1090x/rofi";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [iynaix];
      mainProgram = "rofi-themes";
      platforms = platforms.all;
    };
  })
