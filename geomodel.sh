package: GeoModel
version: "%(tag_basename)s"
tag: "6.22.0"
source: https://gitlab.cern.ch/GeoModelDev/GeoModel.git
requires:
  - boost
  - Eigen3
  - XercesC
  - sqlite
  - nlohmann-json
build_requires:
  - CMake
env:
  GEOMODEL_ROOT: "$GEOMODEL_ROOT"
prepend_path:
  ROOT_INCLUDE_PATH: "$GEOMODEL_ROOT/include"
  PATH: "$GEOMODEL_ROOT/bin"
  LD_LIBRARY_PATH: "$GEOMODEL_ROOT/lib"
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
      -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE} \
      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD} \
      -DBUILD_SHARED_LIBS=ON \
      -DGEOMODEL_BUILD_TOOLS=ON \
      -DGEOMODEL_BUILD_VISUALIZATION=OFF \
      -DGEOMODEL_BUILD_EXAMPLES=OFF \
      -DGEOMODEL_BUILD_TESTING=OFF \
      -DGEOMODEL_BUILD_GEOMODELG4=OFF \
      -DGEOMODEL_USE_BUILTIN_JSON=OFF \
      ${BOOST_ROOT:+-DBoost_ROOT=$BOOST_ROOT} \
      ${EIGEN3_ROOT:+-DEigen3_DIR=$EIGEN3_ROOT/share/eigen3/cmake} \
      ${XERCESC_ROOT:+-DXercesC_DIR=$XERCESC_ROOT} \
      ${SQLITE_ROOT:+-DSQLite3_ROOT=$SQLITE_ROOT} \
      ${NLOHMANN_JSON_ROOT:+-Dnlohmann_json_DIR=$NLOHMANN_JSON_ROOT/share/cmake/nlohmann_json}

cmake --build . ${JOBS:+-j$JOBS}
cmake --install .

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
prepend-path CMAKE_PREFIX_PATH \$PKG_ROOT
setenv GEOMODEL_ROOT \$PKG_ROOT
EoF
