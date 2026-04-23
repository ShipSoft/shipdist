package: data-model
version: "%(tag_basename)s"
tag: main
source: https://github.com/ShipSoft/data-model.git
requires:
  - ROOT
build_requires:
  - CMake
  - GCC-Toolchain
  - alibuild-recipe-tools
prepend_path:
  ROOT_INCLUDE_PATH: "$DATA_MODEL_ROOT/include"
  LD_LIBRARY_PATH: "$DATA_MODEL_ROOT/lib"
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_CXX_STANDARD="${CMAKE_CXX_STANDARD:-23}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_POLICY_DEFAULT_CMP0144=NEW

cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
