package: HepMC3
version: "%(tag_basename)s"
tag: master
source: https://gitlab.cern.ch/hepmc/HepMC3.git
requires:
  - ROOT
build_requires:
  - CMake
  - GCC-Toolchain:(?!osx.*)
  - alibuild-recipe-tools
env:
  "HEPMC3": "$HEPMC3_ROOT"
prepend_path:
  "ROOT_INCLUDE_PATH": "$HEPMC3_ROOT/include"
---
#!/bin/bash -e
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "${MODULEFILE}"

cmake  "$SOURCEDIR"                           \
       -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"  \
       -DCMAKE_INSTALL_LIBDIR=lib           \
       -DROOT_DIR="$ROOT_ROOT"

make ${JOBS+-j $JOBS}
make install

# Modulefile
cat > "$MODULEFILE" <<EoF
# Our environment
set HEPMC3_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$HEPMC3_ROOT/bin
prepend-path LD_LIBRARY_PATH \$HEPMC3_ROOT/lib
prepend-path ROOT_INCLUDE_PATH \$HEPMC3_ROOT/include
EoF
