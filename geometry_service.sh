package: geometry_service
version: "%(tag_basename)s"
tag: main
source: https://github.com/ShipSoft/GeometryService.git
requires:
  - geometry
  - GeoModel
  - GEANT4
  - ms-gsl
  - mp-units
build_requires:
  - CMake
  - GCC-Toolchain
  - alibuild-recipe-tools
env:
  SHIPGEOMETRYSERVICE_ROOT: "$GEOMETRY_SERVICE_ROOT"
prepend_path:
  ROOT_INCLUDE_PATH: "$GEOMETRY_SERVICE_ROOT/include"
  LD_LIBRARY_PATH: "$GEOMETRY_SERVICE_ROOT/lib"
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_CXX_STANDARD="${CMAKE_CXX_STANDARD:-23}" \
  -DCMAKE_PREFIX_PATH="$MS_GSL_ROOT;$MP_UNITS_ROOT" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_POLICY_DEFAULT_CMP0144=NEW \
  -DBUILD_TESTING=OFF

cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
