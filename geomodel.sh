package: GeoModel
version: "%(tag_basename)s"
tag: "6.24.0"
source: https://gitlab.cern.ch/GeoModelDev/GeoModel.git
requires:
  - sqlite
  - XercesC
  - nlohmann_json
  - Eigen3
  - GEANT4
  - opengl
  - Coin3D
  - SoQt
build_requires:
  - CMake
  - "GCC-Toolchain:(?!osx)"
  - alibuild-recipe-tools
env:
  GEOMODEL_ROOT: "$GEOMODEL_ROOT"
prepend_path:
  ROOT_INCLUDE_PATH: "$GEOMODEL_ROOT/include"
  LD_LIBRARY_PATH: "$GEOMODEL_ROOT/lib"
---
#!/bin/bash -e

# Resolve Qt6 cmake config to its real path so _IMPORT_PREFIX does not follow
# LCG view symlinks back to the Qt5 include dir.
IFS=: read -ra _prefixes <<< "${CMAKE_PREFIX_PATH:-}"
for _prefix in "${_prefixes[@]}"; do
  _qt6conf="$_prefix/lib/cmake/Qt6/Qt6Config.cmake"
  if [ -e "$_qt6conf" ]; then
    QT6_DIR=$(dirname "$(readlink -f "$_qt6conf")")
    break
  fi
done

# Derive Qt6 platform-plugin path from the resolved install tree so that
# gmex can find the xcb plugin at runtime without QT_QPA_PLATFORM_PLUGIN_PATH
# being set manually.
if [ -n "${QT6_DIR}" ]; then
  _qt6root="$(dirname "$(dirname "$(dirname "$QT6_DIR")")")"
  if [ -d "$_qt6root/plugins/platforms" ]; then
    QT6_PLATFORM_PLUGIN_PATH="$_qt6root/plugins/platforms"
  fi
fi

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_CXX_STANDARD="${CMAKE_CXX_STANDARD:-20}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  ${CMAKE_PREFIX_PATH:+-DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH"} \
  ${QT6_DIR:+-DQt6_DIR="$QT6_DIR"} \
  -DGEOMODEL_USE_BUILTIN_JSON=OFF \
  -DGEOMODEL_USE_BUILTIN_XERCESC=OFF \
  -DGEOMODEL_USE_BUILTIN_EIGEN3=OFF \
  -DGEOMODEL_BUILD_VISUALIZATION=ON \
  -DGEOMODEL_USE_BUILTIN_COIN3D=OFF \
  -DGEOMODEL_BUILD_GEOMODELG4=ON \
  -DGEOMODEL_BUILD_TOOLS=ON \
  -DGEOMODEL_BUILD_FULLSIMLIGHT=OFF \
  -DGEOMODEL_BUILD_TESTING=OFF

cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
# Our environment
set GEOMODEL_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path ROOT_INCLUDE_PATH \$GEOMODEL_ROOT/include
EoF
if [ -n "${QT6_PLATFORM_PLUGIN_PATH}" ]; then
  cat >> "$MODULEFILE" <<EoF
prepend-path QT_QPA_PLATFORM_PLUGIN_PATH ${QT6_PLATFORM_PLUGIN_PATH}
EoF
fi
