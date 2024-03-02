# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  swww = {
    pname = "swww";
    version = "f77d1e0b4f36c0219270a953411c8edc0c7379bb";
    src = fetchFromGitHub {
      owner = "LGFae";
      repo = "swww";
      rev = "f77d1e0b4f36c0219270a953411c8edc0c7379bb";
      fetchSubmodules = false;
      sha256 = "sha256-I0umponNdG0c9QIC6pxnlNA+pvRGc/jFtKLOvBS/CEY=";
    };
    date = "2024-02-27";
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
    version = "c3017f48ac2efd027f6fe063f94bc51102f191c2";
    src = fetchgit {
      url = "https://codeberg.org/explosion-mental/wallust.git";
      rev = "c3017f48ac2efd027f6fe063f94bc51102f191c2";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-7fcaSNqgZt9nE1onMd8Yg7FgHsqjBgqSk2sclCcsLvA=";
    };
    date = "2024-03-01";
  };
  waybar = {
    pname = "waybar";
    version = "bdff489850931798814da82e797ff10d71b89670";
    src = fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = "bdff489850931798814da82e797ff10d71b89670";
      fetchSubmodules = false;
      sha256 = "sha256-BWdD+bfz/J2fyoC/oy+PR6JrRAsCkKori5wrt0yllaQ=";
    };
    date = "2024-03-01";
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
