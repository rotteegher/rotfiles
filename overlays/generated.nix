# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  hyprcursor = {
    pname = "hyprcursor";
    version = "912d56025f03d41b1ad29510c423757b4379eb1c";
    src = fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprcursor";
      rev = "912d56025f03d41b1ad29510c423757b4379eb1c";
      fetchSubmodules = false;
      sha256 = "sha256-sLADpVgebpCBFXkA1FlCXtvEPu1tdEsTfqK1hfeHySE=";
    };
    date = "2024-08-02";
  };
  hyprlock = {
    pname = "hyprlock";
    version = "9393a3e94d837229714e28041427709756033f5a";
    src = fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprlock";
      rev = "9393a3e94d837229714e28041427709756033f5a";
      fetchSubmodules = false;
      sha256 = "sha256-gr4mN6BYKqy9JDr/ygDlMGYvEYBCMTDDDVnGNp/EYuw=";
    };
    date = "2024-08-05";
  };
  swww = {
    pname = "swww";
    version = "432b7135af0bb34e4b0e55edf76ff516937bc7b0";
    src = fetchFromGitHub {
      owner = "LGFae";
      repo = "swww";
      rev = "432b7135af0bb34e4b0e55edf76ff516937bc7b0";
      fetchSubmodules = false;
      sha256 = "sha256-pX6fJrlNXe1W5ZO9nC9ikN1zoAcHDqErLS7EnglD33o=";
    };
  };
  wallust = {
    pname = "wallust";
    version = "2fe6f577cbd16847f32969c7d18c59556fdc9c2b";
    src = fetchgit {
      url = "https://codeberg.org/explosion-mental/wallust.git";
      rev = "2fe6f577cbd16847f32969c7d18c59556fdc9c2b";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-vZTHlonepK1cyxHhGu3bVBuOmExPtRFrAnYp71Jfs8c=";
    };
    date = "2024-08-05";
  };
}
