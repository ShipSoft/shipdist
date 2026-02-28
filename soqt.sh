package: SoQt
version: "%(tag_basename)s"
tag: "v1.6.4"
source: https://github.com/coin3d/soqt.git
requires:
  - Coin3D
  - "GCC-Toolchain:(?!osx)"
build_requires:
  - CMake
  - alibuild-recipe-tools
env:
  SOQT_ROOT: "$SOQT_ROOT"
prepend_path:
  LD_LIBRARY_PATH: "$SOQT_ROOT/lib"
---
#!/bin/bash -e

git -C "$SOURCEDIR" submodule update --init --recursive

# Resolve Qt6 cmake config to its real path so _IMPORT_PREFIX does not follow
# LCG view symlinks back to the Qt5 include dir.
if [ -n "${CMAKE_PREFIX_PATH}" ]; then
  _qt6conf="${CMAKE_PREFIX_PATH}/lib/cmake/Qt6/Qt6Config.cmake"
  if [ -e "$_qt6conf" ]; then
    QT6_DIR=$(dirname "$(readlink -f "$_qt6conf")")
  fi
fi

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  ${CMAKE_PREFIX_PATH:+-DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH"} \
  ${QT6_DIR:+-DQt6_DIR="$QT6_DIR"} \
  -DSOQT_USE_QT6=ON \
  -DSOQT_BUILD_DOCUMENTATION=OFF \
  -DSOQT_BUILD_EXAMPLES=OFF \
  -DSOQT_BUILD_TESTS=OFF

cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > "$MODULEDIR/$PKGNAME"
