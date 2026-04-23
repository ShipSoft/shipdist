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
  - hdf5
build_requires:
  - CMake
  - GCC-Toolchain
  - alibuild-recipe-tools
env:
  GEOMODEL_ROOT: "$GEOMODEL_ROOT"
prepend_path:
  ROOT_INCLUDE_PATH: "$GEOMODEL_ROOT/include"
  LD_LIBRARY_PATH: "$GEOMODEL_ROOT/lib"
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_CXX_STANDARD="${CMAKE_CXX_STANDARD:-23}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DGEOMODEL_USE_BUILTIN_JSON=OFF \
  -DGEOMODEL_USE_BUILTIN_XERCESC=OFF \
  -DGEOMODEL_USE_BUILTIN_EIGEN3=OFF \
  -DGEOMODEL_BUILD_VISUALIZATION=ON \
  -DGEOMODEL_USE_BUILTIN_COIN3D=OFF \
  -DGEOMODEL_BUILD_GEOMODELG4=ON \
  -DGEOMODEL_BUILD_TOOLS=ON \
  -DGEOMODEL_BUILD_FULLSIMLIGHT=ON \
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
