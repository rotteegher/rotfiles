# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  goo-engine = {
    pname = "goo-engine";
    version = "9d27635972055084ea82017d864dbcd1ea26a058";
    src = fetchFromGitHub {
      owner = "dillongoostudios";
      repo = "goo-engine";
      rev = "9d27635972055084ea82017d864dbcd1ea26a058";
      fetchSubmodules = false;
      sha256 = "sha256-Mld6On+HkNSpvqTV7hfiUQqxby0zZ2Ldc+LWW67jSkY=";
    };
    date = "2023-11-11";
  };
  swww = {
    pname = "swww";
    version = "d60139dffe3fb7ee26814fed292fdcca2309df31";
    src = fetchFromGitHub {
      owner = "Horus645";
      repo = "swww";
      rev = "d60139dffe3fb7ee26814fed292fdcca2309df31";
      fetchSubmodules = false;
      sha256 = "sha256-n7YdUmIZGu7W7cX6OvVW+wbkKjFvont4hEAhZXYDQd8=";
    };
    date = "2024-01-15";
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
    version = "e6740a4a82abd794108582c5a02cd559643d87fa";
    src = fetchgit {
      url = "https://codeberg.org/explosion-mental/wallust.git";
      rev = "e6740a4a82abd794108582c5a02cd559643d87fa";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-lwai3vaq/osEEuZmOVBPqgF6mzxFPbgU9fNWHhv0rWs=";
    };
    date = "2024-01-11";
  };
  waybar = {
    pname = "waybar";
    version = "07eabc5328dc5056f667a93f58549314d10f007b";
    src = fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = "07eabc5328dc5056f667a93f58549314d10f007b";
      fetchSubmodules = false;
      sha256 = "sha256-Tbhj9nAP3PoECFWVVk3bciM+x1Vw6MVo779OqSFfZ/Y=";
    };
    date = "2024-01-14";
  };
  wezterm = {
    pname = "wezterm";
    version = "6c36a4dda2527836af0e0aa076d5dd0bd8d3dd79";
    src = fetchFromGitHub {
      owner = "wez";
      repo = "wezterm";
      rev = "6c36a4dda2527836af0e0aa076d5dd0bd8d3dd79";
      fetchSubmodules = true;
      sha256 = "sha256-bWcez8vJlZttrVmBjyXZBZIbSBE7tpu1lkVSH1T6Fw0=";
    };
    date = "2024-01-11";
  };
}
