package: acts
version: shipdist-build
source: https://github.com/webbjm/acts.git
requires:
  - ROOT
  - GEANT4
  - pythia
  - HepMC3
  - CMake
  - boost
  - alibuild-recipe-tools
---
#!/bin/bash -e

cmake "$SOURCEDIR" -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_SKIP_RPATH=TRUE \
  -DCMAKE_PREFIX_PATH="${PYTHIA_ROOT}" \
  -DGeant4_DIR=${GEANT4_ROOT}/lib           \
  -DACTS_BUILD_FATRAS=ON \
  -DACTS_BUILD_PLUGIN_GEANT4=ON \
  -DACTS_BUILD_FATRAS_GEANT4=ON \
  -DACTS_BUILD_ANALYSIS_APPS=ON \
  -DACTS_BUILD_PLUGIN_TGEO=ON \
  -DACTS_BUILD_EXAMPLES=ON \
  -DACTS_BUILD_EXAMPLES_PYTHON_BINDINGS=ON \
  -DACTS_BUILD_EXAMPLES_PYTHIA8=ON \
  -DACTS_BUILD_EXAMPLES_GEANT4=ON \
  -DCMAKE_VERBOSE_MAKEFILE=1 \
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}


cmake --build . -- ${JOBS:+-j$JOBS} install

[[ -d $INSTALLROOT/lib64 ]] && [[ ! -d $INSTALLROOT/lib ]] && ln -sf ${INSTALLROOT}/lib64 $INSTALLROOT/lib

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "${MODULEFILE}"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
if ![ is-loaded 'BASE/1.0' ] {
 module load BASE/1.0
}

if ![ is-loaded "ROOT/$ROOT_VERSION-$ROOT_REVISION" ] { module load "ROOT/$ROOT_VERSION-$ROOT_REVISION"}
set ACTS_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$ACTS_ROOT/lib
prepend-path ROOT_INCLUDE_PATH \$ACTS_ROOT/include
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(ACTS_ROOT)/lib")
EoF
