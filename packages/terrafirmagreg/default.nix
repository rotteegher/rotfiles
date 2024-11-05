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
    // {
      sourceRoot = ".";
      nativeBuildInputs = [
        pkgs.curl
        pkgs.openssl
        pkgs.unzip
      ];
      BuildInputs = [
      ];
      installPhase = ''
        ls -la .
        mkdir $out
        cp -r ./* $out/
        ls -la .
        ls -la $out/
        # install -m755 -D .minecraft/ $out/bin/bedrock_server
        # rm bedrock_server
        # rm server.properties
        # mkdir -p $out/var
        # cp -a . $out/var/lib
      '';
      # fixupPhase = ''
      #   autoPatchelf $out/bin/bedrock_server
      # '';
    })
)
