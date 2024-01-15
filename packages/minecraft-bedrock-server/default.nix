{ 
config,
lib,
pkgs,
stdenvNoCC,
source,
...
}:

stdenvNoCC.mkDerivation (
  finalAttrs: (source
  //  {
    sourceRoot = ".";
    nativeBuildInputs = [
      (pkgs.patchelf.overrideDerivation(old: {
        postPatch = ''
          substituteInPlace src/patchelf.cc \
            --replace "32 * 1024 * 1024" "512 * 1024 * 1024"
        '';
      }))
      pkgs.autoPatchelfHook
      pkgs.curl
      pkgs.gcc-unwrapped
      pkgs.openssl
      pkgs.unzip
    ];
    BuildInputs = [
      
    ];
    installPhase = ''
      install -m755 -D bedrock_server $out/bin/bedrock_server
      rm bedrock_server 
      rm server.properties
      mkdir -p $out/var
      cp -a . $out/var/lib
    '';
    fixupPhase = ''
      autoPatchelf $out/bin/bedrock_server
    '';
  })
)
