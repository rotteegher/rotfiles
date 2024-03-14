# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  swww = {
    pname = "swww";
    version = "0516ea09e5d7e8194d53760a71bc5bb3cd5de30b";
    src = fetchFromGitHub {
      owner = "LGFae";
      repo = "swww";
      rev = "0516ea09e5d7e8194d53760a71bc5bb3cd5de30b";
      fetchSubmodules = false;
      sha256 = "sha256-HfGHkSCal2fd+/y9sk0+9sv5WAKssL2OJk/UeB5qNPw=";
    };
    date = "2024-03-11";
  };
  transmission-web-soft-theme = {
    pname = "transmission-web-soft-theme";
    version = "a957b41b0303e6b74e67191311e0d2af9b60a965";
    src = fetchFromGitHub {
      owner = "diesys";
      repo = "transmission-web-soft-theme";
      rev = "a957b41b0303e6b74e67191311e0d2af9b60a965";
      fetchSubmodules = false;
      sha256 = "sha256-KngN44lnhv0sga0otYC9F5xoqLDDIVxobXRlhhhSmHo=";
    };
    date = "2021-01-28";
  };
  wallust = {
    pname = "wallust";
    version = "104d99fcb4ada743d45de76caa48cd899b021601";
    src = fetchgit {
      url = "https://codeberg.org/explosion-mental/wallust.git";
      rev = "104d99fcb4ada743d45de76caa48cd899b021601";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-gGyxRdv2I/3TQWrTbUjlJGsaRv4SaNE+4Zo9LMWmxk8=";
    };
    date = "2024-03-08";
  };
  waybar = {
    pname = "waybar";
    version = "214858f413fa70166ed945f973b12b3eaddf6548";
    src = fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = "214858f413fa70166ed945f973b12b3eaddf6548";
      fetchSubmodules = false;
      sha256 = "sha256-BCtoMojRULSgiE9NcojAerKaVeav2yMovrzkBQFaUSA=";
    };
    date = "2024-03-12";
  };
  wezterm = {
    pname = "wezterm";
    version = "22424c3280cb21af43317cb58ef7bc34a8cbcc91";
    src = fetchFromGitHub {
      owner = "wez";
      repo = "wezterm";
      rev = "22424c3280cb21af43317cb58ef7bc34a8cbcc91";
      fetchSubmodules = true;
      sha256 = "sha256-EQb0gNAb98e4IFwBv5XODtq9Er519wM/h5EglD8Lrhc=";
    };
    date = "2024-02-26";
  };
}
