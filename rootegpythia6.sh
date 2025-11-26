package: ROOTEGPythia6
version: "%(tag_basename)s"
tag: main
source: https://github.com/luketpickering/ROOTEGPythia6
requires:
  - ROOT
  - GCC-Toolchain:(?!osx)
build_requires:
  - CMake
env:
  ROOTEGPYTHIA6: "$ROOTEGPYTHIA6_ROOT"
prepend_path:
  LD_LIBRARY_PATH: "$ROOTEGPYTHIA6_ROOT/lib"
  ROOT_INCLUDE_PATH: "$ROOTEGPYTHIA6_ROOT/include"
  CMAKE_MODULE_PATH: "$ROOTEGPYTHIA6_ROOT/lib/cmake/ROOTEGPythia6/Modules"
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
      -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -DROOTEGPythia6_Pythia6_BUILTIN=ON \
      -DCMAKE_INSTALL_LIBDIR=lib

cmake --build . ${JOBS:+-j$JOBS}
cmake --install .

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EOF
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
EOF
