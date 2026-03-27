package: PHLEX
version: "%(tag_basename)s"
tag: v0.1.0
source: https://github.com/Framework-R-D/phlex
requires:
  - "GCC-Toolchain:(?!osx)"
  - boost
  - fmt
  - TBB
  - spdlog
  - jsonnet
  - ROOT
build_requires:
  - CMake
  - cetmodules
  - alibuild-recipe-tools
env:
  PHLEX_ROOT: "$PHLEX_ROOT"
  PHLEX_PLUGIN_PATH: "$PHLEX_ROOT/lib"
prepend_path:
  ROOT_INCLUDE_PATH: "$PHLEX_ROOT/include"
  LD_LIBRARY_PATH: "$PHLEX_ROOT/lib"
---
#!/bin/bash -e

# PHLEX requires C++23 regardless of defaults
export CXXFLAGS="${CXXFLAGS//-std=c++*/-std=c++23}"

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_PREFIX_PATH="$CETMODULES_ROOT" \
  -DPHLEX_USE_FORM=ON \
  -DBUILD_TESTING=OFF \
  -DENABLE_CLANG_TIDY=OFF

cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
# Our environment
set PHLEX_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv PHLEX_PLUGIN_PATH \$PHLEX_ROOT/lib
prepend-path ROOT_INCLUDE_PATH \$PHLEX_ROOT/include
EoF
