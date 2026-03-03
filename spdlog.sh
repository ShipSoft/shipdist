package: spdlog
version: "%(tag_basename)s"
tag: v1.15.2
source: https://github.com/gabime/spdlog
requires:
  - "GCC-Toolchain:(?!osx)"
  - fmt
build_requires:
  - CMake
  - alibuild-recipe-tools
prepend_path:
  ROOT_INCLUDE_PATH: "$SPDLOG_ROOT/include"
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_PREFIX_PATH="$FMT_ROOT" \
  -DSPDLOG_FMT_EXTERNAL=ON \
  -DSPDLOG_BUILD_SHARED=ON \
  -DSPDLOG_BUILD_EXAMPLE=OFF \
  -DSPDLOG_BUILD_TESTS=OFF

cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
# Our environment
set SPDLOG_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv SPDLOG_ROOT \$SPDLOG_ROOT
prepend-path LD_LIBRARY_PATH \$SPDLOG_ROOT/lib
prepend-path ROOT_INCLUDE_PATH \$SPDLOG_ROOT/include
EoF
