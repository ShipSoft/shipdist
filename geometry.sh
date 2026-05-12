package: geometry
version: "%(tag_basename)s"
tag: "v0.1.0"
source: https://github.com/ShipSoft/Geometry.git
requires:
  - GeoModel
  - Eigen3
  - sqlite
build_requires:
  - CMake
  - GCC-Toolchain
  - alibuild-recipe-tools
env:
  SHIPGEOMETRY_ROOT: "$GEOMETRY_ROOT"
prepend_path:
  ROOT_INCLUDE_PATH: "$GEOMETRY_ROOT/include"
  LD_LIBRARY_PATH: "$GEOMETRY_ROOT/lib"
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_CXX_STANDARD="${CMAKE_CXX_STANDARD:-23}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_POLICY_DEFAULT_CMP0144=NEW \
  -DSQLite3_ROOT="$SQLITE_ROOT"

cmake --build . -- ${JOBS:+-j$JOBS} install

# Generate the pre-built geometry database
mkdir -p "$INSTALLROOT/share/geometry"
"$INSTALLROOT/bin/build_geometry" "$INSTALLROOT/share/geometry/ship_geometry.db"

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
