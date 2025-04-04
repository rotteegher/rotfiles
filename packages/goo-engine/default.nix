{
  pkgs,
  source,
  vulkan-tools,
  vulkan-loader,
  vulkan-headers,
  vulkan-validation-layers,
  shaderc,
  imath,

  addDriverRunpath,
  alembic,
  boost,
  cmake,
  colladaSupport ? true,
  config,
  cudaPackages,
  cudaSupport ? config.cudaSupport,
  dbus,
  embree,
  fetchzip,
  # ffmpeg,
  fftw,
  fftwFloat,
  freetype,
  gettext,
  glew,
  gmp,
  hipSupport ? false,
  jackaudioSupport ? false,
  jemalloc,
  lib,
  libGL,
  libGLU,
  libX11,
  libXext,
  libXi,
  libXrender,
  libXxf86vm,
  libdecor,
  libepoxy,
  libffi,
  libharu,
  libjack2,
  libjpeg,
  libpng,
  libsamplerate,
  libsndfile,
  libspnav,
  libtiff,
  libwebp,
  libxkbcommon,
  llvmPackages,
  makeWrapper,
  materialx,
  ocl-icd,
  openal,
  opencollada,
  opencolorio,
  openusd,
  openexr_3,
  # openexr,
  openimagedenoise,
  openimageio,
  openjpeg,
  # openpgl,
  opensubdiv,
  openvdb,
  openxr-loader,
  pkg-config,
  potrace,
  pugixml,
  python311Packages, # must use instead of python3.pkgs, see https://github.com/NixOS/nixpkgs/issues/211340
  rocmPackages, # comes with a significantly larger closure size
  spaceNavSupport ? stdenv.isLinux,
  stdenv,
  tbb,
  wayland,
  wayland-protocols,
  wayland-scanner,
  egl-wayland,
  eglexternalplatform,
  glfw,
  freeglut,
  mesa,
  waylandSupport ? stdenv.isLinux,
  zlib,
  zstd,
}:

let
  python3Packages = python311Packages;
  python3 = python3Packages.python;
  # pyPkgsOpenusd = python3Packages.openusd.override { withOsl = false; };
  # pyPkgsOpenusd = openusd;

  libdecor' = libdecor.overrideAttrs (old: {
    # Blender uses private APIs, need to patch to expose them
    patches = (old.patches or [ ]) ++ [ ./libdecor.patch ];
  });

  optix = fetchzip {
    # URL from https://gitlab.archlinux.org/archlinux/packaging/packages/blender/-/commit/333add667b43255dcb011215a2d2af48281e83cf#9b9baac1eb9b72790eef5540a1685306fc43fd6c_30_30
    url = "https://developer.download.nvidia.com/redist/optix/v7.3/OptiX-7.3.0-Include.zip";
    hash = "sha256-aMrp0Uff4c3ICRn4S6zedf6Q4Mc0/duBhKwKgYgMXVU=";
  };
in

stdenv.mkDerivation (
  finalAttrs:
  (
    source
    // {
      # patches = [ ./draco.patch ];

      postPatch =
        (''
          substituteInPlace extern/clew/src/clew.c --replace '"libOpenCL.so"' '"${ocl-icd}/lib/libOpenCL.so"'
        '')
        + (lib.optionalString hipSupport ''
          substituteInPlace extern/hipew/src/hipew.c --replace '"/opt/rocm/hip/lib/libamdhip64.so"' '"${rocmPackages.clr}/lib/libamdhip64.so"'
          substituteInPlace extern/hipew/src/hipew.c --replace '"opt/rocm/hip/bin"' '"${rocmPackages.clr}/bin"'
        '');

      env.NIX_CFLAGS_COMPILE = "-I${python3}/include/${python3.libPrefix}";


      cmakeFlags =
        [
          "-DPYTHON_INCLUDE_DIR=${python3}/include/${python3.libPrefix}"
          "-DPYTHON_LIBPATH=${python3}/lib"
          "-DPYTHON_LIBRARY=${python3.libPrefix}"
          "-DPYTHON_NUMPY_INCLUDE_DIRS=${python3Packages.numpy}/${python3.sitePackages}/numpy/core/include"
          "-DPYTHON_NUMPY_PATH=${python3Packages.numpy}/${python3.sitePackages}"
          "-DPYTHON_VERSION=${python3.pythonVersion}"
          "-DWITH_ALEMBIC=ON"
          "-DWITH_CODEC_FFMPEG=OFF" # turned off to make it compile
          "-DWITH_CODEC_SNDFILE=ON"
          "-DWITH_FFTW3=ON"
          "-DWITH_IMAGE_OPENJPEG=ON"
          "-DWITH_INSTALL_PORTABLE=OFF"
          "-DMaterialX_DIR=${materialx}/lib/cmake/MaterialX"
          "-DWITH_MOD_OCEANSIM=ON"
          "-DWITH_OPENCOLLADA=${if colladaSupport then "ON" else "OFF"}"
          "-DWITH_OPENCOLORIO=ON"
          "-DWITH_OPENSUBDIV=ON"
          "-DWITH_PYTHON_INSTALL=OFF"
          "-DWITH_PYTHON_INSTALL_NUMPY=OFF"
          "-DWITH_PYTHON_INSTALL_REQUESTS=OFF"
          "-DWITH_SDL=OFF"
          "-DWITH_TBB=ON"
          # "-DWITH_USD=ON"
          "-DWITH_USD=OFF"

          # temporary turn offs
          # "-DWITH_CYCLES=OFF" # cycles kinda needed to make everything work even though it compiles
          "-DWITH_CYCLES_EMBREE=OFF"
          "-DWITH_OPENVDB=OFF" # FOG STUFF
          "-DWITH_OPENPGL=OFF"

          # Blender supplies its own FindAlembic.cmake (incompatible with the Alembic-supplied config file)
          "-DALEMBIC_INCLUDE_DIR=${lib.getDev alembic}/include"
          "-DALEMBIC_LIBRARY=${lib.getLib alembic}/lib/libAlembic${stdenv.hostPlatform.extensions.sharedLibrary}"

          "-DOPENGLES_EGL_LIBRARY=${pkgs.lib.makeLibraryPath [ glfw egl-wayland ]}"

          # Wayland support
          "-DWITH_GHOST_WAYLAND=ON"
          "-DWITH_GHOST_WAYLAND_DBUS=ON"
          "-DWITH_GHOST_WAYLAND_DYNLOAD=OFF"
          "-DWITH_GHOST_WAYLAND_LIBDECOR=ON"

        ]
        ++ lib.optionals (stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isLinux) [
        ]
        ++ lib.optional stdenv.cc.isClang "-DPYTHON_LINKFLAGS=" # Clang doesn't support "-export-dynamic"
        ++ lib.optional jackaudioSupport "-DWITH_JACK=ON"
        ++ lib.optionals cudaSupport [
          "-DOPTIX_ROOT_DIR=${optix}"
          "-DWITH_CYCLES_CUDA_BINARIES=ON"
          "-DWITH_CYCLES_DEVICE_OPTIX=ON"
        ];

      nativeBuildInputs = [
        cmake
        llvmPackages.llvm.dev
        makeWrapper
        python3Packages.wrapPython
        addDriverRunpath
        cudaPackages.cuda_nvcc
        pkg-config

        glfw
      ];

      buildInputs =
        [


          addDriverRunpath
          # vulkan-tools
          vulkan-loader
          # vulkan-headers
          # vulkan-validation-layers
          shaderc
          imath

          alembic
          boost
          # ffmpeg
          fftw
          fftwFloat
          freetype
          gettext
          glew
          gmp
          jemalloc
          libepoxy
          libharu
          libjpeg
          libpng
          libsamplerate
          libsndfile
          libtiff
          libwebp
          materialx
          opencolorio
          openexr_3
          # openexr
          openimageio
          openjpeg
          # openpgl
          (opensubdiv.override { inherit cudaSupport; })
          openvdb
          potrace
          pugixml
          python3
          tbb
          zlib
          zstd

          # linux stuff:
          embree
          mesa

          dbus
          libdecor'
          libffi
          libxkbcommon
          wayland
          wayland-protocols
          wayland-scanner
          egl-wayland
          eglexternalplatform
          glfw
          freeglut

          libGL
          libGL.out
          libGL.dev
          libGLU
          libX11
          libXext
          libXi
          libXrender
          libXxf86vm
          openal
          openxr-loader
          # pyPkgsOpenusd
        ]
        ++ lib.optionals (!stdenv.isAarch64 && stdenv.isLinux) [
          (openimagedenoise.override { inherit cudaSupport; })
        ]
        ++ lib.optionals cudaSupport [ cudaPackages.cuda_cudart ]
        ++ lib.optional colladaSupport opencollada
        ++ lib.optional jackaudioSupport libjack2
        ++ lib.optional spaceNavSupport libspnav;

      pythonPath =
        let
          ps = python3Packages;
        in
        [
          materialx
          ps.numpy
          ps.requests
          ps.zstandard
        ];

      blenderExecutable = placeholder "out" + ("/bin/goo-engine");

      buildPhase = ''
        # debug
        echo "\n"
        cat Makefile
        echo "\n"

        echo "Current Build Dir: $(pwd)"
        ${pkgs.eza}/bin/eza -la --group-directories-first --git-ignore --icons --tree --hyperlink --level 3
        echo "\n"

        mkdir -p $out/bin
        echo "Source: $src"
        ${pkgs.eza}/bin/eza -la --group-directories-first --git-ignore --icons --tree --hyperlink --level 3 $src
        echo "Output: $out"
        ${pkgs.eza}/bin/eza -la --group-directories-first --git-ignore --icons --tree --hyperlink --level 3 $out
        echo "\n"

        echo "Making install"
        make install

        echo "Output AFTER MAKE INSTALL: $out"
        ${pkgs.eza}/bin/eza -la --group-directories-first --git-ignore --icons --tree --hyperlink --level 3 $out
      '';

      installPhase = ''
        # cp -r share/* "$out/share/"
        # cp -r $src/share/blender $out/share
        # cp -r $src/share/doc $out/share
        # cp -r $src/share/icons $out/share

        echo "Blender Desktop Entry:"
        cat $out/share/applications/blender.desktop
        cp -v $out/share/applications/blender.desktop $out/share/applications/${finalAttrs.finalPackage.pname}.desktop

        echo "Unmodified:"
        cat $out/share/applications/${finalAttrs.finalPackage.pname}.desktop

        sed -i -e 's/Exec=blender/Exec=${finalAttrs.finalPackage.pname}/g' -e 's/Name=Blender/Name=Goo-Engine/g' $out/share/applications/${finalAttrs.finalPackage.pname}.desktop

        echo "Modified Goo Engine Desktop Entry:"
        cat $out/share/applications/${finalAttrs.finalPackage.pname}.desktop

        rm $out/share/applications/blender.desktop

        echo "Desktop Entries:"
        ls -lag $out/share/applications

        buildPythonPath "$pythonPath"

        # makeWrapper bin/blender $out/bin/${finalAttrs.finalPackage.pname} \
        #   --prefix PATH : $program_PATH \
        #   --prefix PYTHONPATH : $program_PYTHONPATH

        echo "Listing $out bin"
        ls -lah $out/bin

        echo "after Renaming blender bin"
        mv $out/bin/blender $out/bin/${finalAttrs.finalPackage.pname}
        ls -lah $out/bin

        echo "Current Build Dir:"
        ${pkgs.eza}/bin/eza -la --group-directories-first --git-ignore --icons --tree --hyperlink --level 3
        echo "Output:"
        ${pkgs.eza}/bin/eza -la --group-directories-first --git-ignore --icons --tree --hyperlink --level 3 $out
        echo Installation Success!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        file $out/bin/goo-engine
        $out/bin/goo-engine --version
      '';

      postInstall =
        lib.optionalString stdenv.isLinux ''
          mv $out/share/blender/${lib.versions.majorMinor finalAttrs.version}/python{,-ext}
        ''
        + ''
          buildPythonPath "$pythonPath"
          wrapProgram $blenderExecutable \
            --prefix PATH : $program_PATH \
            --prefix PYTHONPATH : "$program_PYTHONPATH" \
            --add-flags '--python-use-system-env'
        '';

      # Set RUNPATH so that libcuda and libnvrtc in /run/opengl-driver(-32)/lib can be
      # found. See the explanation in libglvnd.
      postFixup = lib.optionalString cudaSupport "
    for program in \"$out/bin/goo-engine\" \"$out/bin/.goo-engine-wrapped\"; do
        isELF \"$program\" || continue

        forceRpath=
        while [ $# -gt 0 ]; do
          case \"$1\" in
            --) shift; break;;
            --force-rpath) shift; forceRpath=1;;
            --*)
              echo \"addDriverRunpath: ERROR: Invalid command line\" \
                   \"argument: $1\" >&2
              return 1;;
            *) break;;
          esac
        done  


        origRpath=\"$(patchelf --print-rpath \"$program\")\"
        patchelf --set-rpath \"/run/opengl-driver/lib:$origRpath\" \${forceRpath:+--force-rpath} \"$program\"
      done
    ";

      # passthru = {
      #   python = python3;
      #   pythonPackages = python3Packages;

      #   withPackages =
      #     f:
      #     (callPackage ./wrapper.nix { }).override {
      #       blender = finalAttrs.finalPackage;
      #       extraModules = (f python3Packages);
      #     };

      #   tests = {
      #     render = runCommand "${finalAttrs.pname}-test" { } ''
      #       set -euo pipefail
      #       export LIBGL_DRIVERS_PATH=${mesa.drivers}/lib/dri
      #       export __EGL_VENDOR_LIBRARY_FILENAMES=${mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json
      #       cat <<'PYTHON' > scene-config.py
      #       import bpy
      #       bpy.context.scene.eevee.taa_render_samples = 32
      #       bpy.context.scene.cycles.samples = 32
      #       if ${if (stdenv.isAarch64 && stdenv.isLinux) then "True" else "False"}:
      #           bpy.context.scene.cycles.use_denoising = False
      #       bpy.context.scene.render.resolution_x = 100
      #       bpy.context.scene.render.resolution_y = 100
      #       bpy.context.scene.render.threads_mode = 'FIXED'
      #       bpy.context.scene.render.threads = 1
      #       PYTHON

      #       mkdir $out
      #       for engine in BLENDER_EEVEE CYCLES; do
      #         echo "Rendering with $engine..."
      #         # Beware that argument order matters
      #         ${lib.getExe finalAttrs.finalPackage} \
      #           --background \
      #           -noaudio \
      #           --factory-startup \
      #           --python-exit-code 1 \
      #           --python scene-config.py \
      #           --engine "$engine" \
      #           --render-output "$out/$engine" \
      #           --render-frame 1
      #       done
      #     '';
      #   };
      # };

      meta = {
        description = "3D Creation/Animation/Publishing System";
        homepage = "https://www.blender.org";
        # They comment two licenses: GPLv2 and Blender License, but they
        # say: "We've decided to cancel the BL offering for an indefinite period."
        # OptiX, enabled with cudaSupport, is non-free.
        license = with lib.licenses; [ gpl2Plus ] ++ lib.optional cudaSupport unfree;
        platforms = [
          "aarch64-linux"
          # "x86_64-darwin"
          "x86_64-linux"
          # "aarch64-darwin"
        ];
        # the current apple sdk is too old (currently 11_0) and fails to build "metal" on x86_64-darwin
        broken = stdenv.hostPlatform.system == "x86_64-darwin";
        maintainers = with lib.maintainers; [
          goibhniu
          veprbl
        ];
        mainProgram = "goo-engine";
      };
    }
  )
)
