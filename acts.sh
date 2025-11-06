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
  - Eigen3
  - alibuild-recipe-tools
---
#!/bin/bash -e

cmake "$SOURCEDIR" -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_SKIP_RPATH=TRUE \
  -DCMAKE_PREFIX_PATH="${PYTHIA_ROOT}" \
  -DGeant4_DIR="${GEANT4_ROOT}/lib"           \
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
  -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}"


cmake --build . -- ${JOBS:+-j$JOBS} install

[[ -d "$INSTALLROOT/lib64" ]] && [[ ! -d "$INSTALLROOT/lib" ]] && ln -sf "${INSTALLROOT}/lib64" "$INSTALLROOT/lib"

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "${MODULEFILE}"

cat << EoF >> "$MODULEFILE"
set ACTS_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv ACTS_ROOT \$ACTS_ROOT
prepend-path LD_LIBRARY_PATH \$ACTS_ROOT/lib
prepend-path ROOT_INCLUDE_PATH \$ACTS_ROOT/include
prepend-path PYTHONPATH \$ACTS_ROOT/python
EoF
