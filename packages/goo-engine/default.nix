{ stdenvNoCC, source, pkgs, lib }:
let
  py = pkgs.python310;
  # Explicit dependency on libepoxy
  libepoxy = pkgs.libepoxy;

  cmakeFlags = [
    "-DWITH_TBB=ON"
    "-DWITH_ALEMBIC=ON"
    "-DWITH_MOD_OCEANSIM=ON"
    "-DWITH_FFTW3=ON"
    "-DWITH_INSTALL_PORTABLE=OFF"
    "-DWITH_LIBS_PRECOMPILED=ON"
    "-DWITH_EPOXY=ON"
    "-DWITH_TIFF=ON"
    "-DWITH_VULKAN=ON"
    "-DWITH_SHADERC=ON"
    # Python
    "-DWITH_PYTHON_MODULE=OFF"
    "-DWITH_PYTHON_INSTALL_NUMPY=OFF"
    "-DWITH_PYTHON_INSTALL_ZSTANDARD=OFF"
    "-DWITH_PYTHON_SAFETY=ON"
    # OpenGL
    "-DWITH_GL_EGL=ON"
    "-DWITH_GLEW_ES=ON"
    # Compilers
    "-DCC=${pkgs.gcc}"
    "-DCXX=${pkgs.gcc}"
  ];
in
stdenvNoCC.mkDerivation (
  finalAttrs: (source
  //  {
    python = py;

    cmakeFlags = cmakeFlags;
    enableParallelBuilding = true;
    nativeBuildInputs = [
      pkgs.cmake
      pkgs.git
      py
      pkgs.pkg-config
      pkgs.dig
    ];
    buildInputs = with pkgs; [
      gcc libgcc
      shaderc
      vulkan-tools vulkan-loader vulkan-headers
      libtiff libepoxy libjpeg libpng zstd freetype openimageio2 opencolorio openexr_3
      embree boost ffmpeg_5 tbb fftw libGL libGLU glew
      xorg.libX11 xorg.libXi xorg.libXxf86vm xorg.libXrender
      # Python packages
      python310Packages.numpy python310Packages.requests
    ];

    pythonPath = with pkgs.python310Packages; [numpy requests zstd python];

    buildPhase = ''
      cd ${source.src}
      echo "THIS IS $(pwd)"
      stat ${pkgs.bash}/bin/bash
    '';

    postPatch = ''
      rm build_files/cmake/Modules/FindPython.cmake
    '';

    phases = ["unpackPhase" "buildPhase" "installPhase"];
    
  })
)
