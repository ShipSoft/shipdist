package: SoQt
version: "%(tag_basename)s"
tag: "v1.6.4"
source: https://github.com/coin3d/soqt.git
requires:
  - Coin3D
  - GCC-Toolchain
build_requires:
  - CMake
  - alibuild-recipe-tools
prefer_system: .*
prefer_system_check: |
  #!/bin/bash -e
  printf '#include <Inventor/Qt/SoQt.h>\nint main(){}\n' | \
    c++ -std=c++20 -xc++ - \
    $(pkg-config --cflags --libs Qt6Core Qt6Widgets Qt6OpenGL) \
    -lSoQt -lCoin -o /dev/null
env:
  SOQT_ROOT: "$SOQT_ROOT"
prepend_path:
  LD_LIBRARY_PATH: "$SOQT_ROOT/lib"
---
#!/bin/bash -e

git -C "$SOURCEDIR" submodule update --init --recursive

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DSOQT_USE_QT6=ON \
  -DSOQT_BUILD_DOCUMENTATION=OFF \
  -DSOQT_BUILD_EXAMPLES=OFF \
  -DSOQT_BUILD_TESTS=OFF

cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > "$MODULEDIR/$PKGNAME"
