package: HepMC3
version: "%(tag_basename)s"
tag: master
source: https://gitlab.cern.ch/hepmc/HepMC3.git
requires:
  - ROOT
build_requires:
  - CMake
  - GCC-Toolchain
  - alibuild-recipe-tools
env:
  "HEPMC3": "$HEPMC3_ROOT"
prepend_path:
  "ROOT_INCLUDE_PATH": "$HEPMC3_ROOT/include"
prefer_system_check: |
  ls $HEPMC3_ROOT/include/HepMC3 && ls $HEPMC3_ROOT/lib/libHepMC3.so
---
#!/bin/bash -e
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "${MODULEFILE}"

cmake  "$SOURCEDIR"                           \
       -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"  \
       -DCMAKE_INSTALL_LIBDIR=lib           \
       -DHEPMC3_ENABLE_PYTHON=OFF           \
       -DROOT_DIR="$ROOT_ROOT"

make ${JOBS+-j $JOBS}
make install

# Modulefile
cat << EoF >> "$MODULEFILE"
# Our environment
set HEPMC3_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$HEPMC3_ROOT/bin
prepend-path LD_LIBRARY_PATH \$HEPMC3_ROOT/lib
prepend-path ROOT_INCLUDE_PATH \$HEPMC3_ROOT/include
EoF
