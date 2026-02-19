package: abseil
version: "%(tag_basename)s"
tag: "20240722.0"
requires:
  - "GCC-Toolchain:(?!osx)"
source: https://github.com/abseil/abseil-cpp
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
prepend_path:
  PKG_CONFIG_PATH: "$ABSEIL_ROOT/lib/pkgconfig"
---
#!/bin/bash -e

cmake $SOURCEDIR                             \
  -G Ninja                                   \
  ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}    \
  -DCMAKE_INSTALL_LIBDIR=lib                 \
  -DBUILD_TESTING=OFF                        \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

cmake --build . -- ${JOBS:+-j$JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib --bin --cmake > "$MODULEFILE"
