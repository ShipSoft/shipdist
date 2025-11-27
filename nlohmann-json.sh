package: nlohmann-json
version: "%(tag_basename)s"
tag: v3.12.0
source: https://github.com/nlohmann/json
build_requires:
  - CMake
  - alibuild-recipe-tools
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
      -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
      ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE} \
      -DJSON_BuildTests=OFF \
      -DJSON_Install=ON

cmake --build . ${JOBS:+-j$JOBS}
cmake --install .

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0
# Our environment
set NLOHMANN_JSON_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv NLOHMANN_JSON_ROOT \$NLOHMANN_JSON_ROOT
prepend-path ROOT_INCLUDE_PATH \$NLOHMANN_JSON_ROOT/include
prepend-path CMAKE_PREFIX_PATH \$NLOHMANN_JSON_ROOT
EoF
