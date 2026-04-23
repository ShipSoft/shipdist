package: Coin3D
version: "%(tag_basename)s"
tag: "v4.0.7"
source: https://github.com/coin3d/coin.git
requires:
  - GCC-Toolchain
build_requires:
  - CMake
  - alibuild-recipe-tools
prefer_system: .*
prefer_system_check: |
  #!/bin/bash -e
  printf '#include <Inventor/SoDB.h>\nint main(){SoDB::init();}\n' | \
    c++ -std=c++20 -xc++ - -lCoin -o /dev/null
env:
  COIN3D_ROOT: "$COIN3D_ROOT"
prepend_path:
  LD_LIBRARY_PATH: "$COIN3D_ROOT/lib"
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCOIN_BUILD_DOCUMENTATION=OFF \
  -DCOIN_BUILD_EXAMPLES=OFF \
  -DCOIN_BUILD_TESTS=OFF

cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > "$MODULEDIR/$PKGNAME"
