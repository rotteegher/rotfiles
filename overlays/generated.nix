# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  hyprcursor = {
    pname = "hyprcursor";
    version = "7c3aa03dffb53921e583ade3d4ae3f487e390e7e";
    src = fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprcursor";
      rev = "7c3aa03dffb53921e583ade3d4ae3f487e390e7e";
      fetchSubmodules = false;
      sha256 = "sha256-J069Uhv/gCMFLX1dSh2f+9ZTM09r1Nv3oUfocCnWKow=";
    };
    date = "2024-05-15";
  };
  hyprlock = {
    pname = "hyprlock";
    version = "997f222b0fec6ac74ec718b53600e77c2b26860a";
    src = fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprlock";
      rev = "997f222b0fec6ac74ec718b53600e77c2b26860a";
      fetchSubmodules = false;
      sha256 = "sha256-WD6Iyb9DV1R5a2A0UIVT8GyzRhs9ntOPGKDubEUUVNs=";
    };
    date = "2024-05-17";
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
}
