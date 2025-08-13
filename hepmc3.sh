package: HepMC3
version: "%(tag_basename)s"
tag: master
source: https://gitlab.cern.ch/hepmc/HepMC3.git
requires:
  - ROOT
build_requires:
  - CMake
  - GCC-Toolchain:(?!osx.*)
env:
  "HEPMC3": $HEPMC3_ROOT
prepend_path:
  "ROOT_INCLUDE_PATH": "$HEPMC3_ROOT/include"
---
#!/bin/bash -e

cmake  $SOURCEDIR                           \
       -DCMAKE_INSTALL_PREFIX=$INSTALLROOT  \
       -DCMAKE_INSTALL_LIBDIR=lib           \
       -DROOT_DIR=$ROOT_ROOT

make ${JOBS+-j $JOBS}
make install

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
#module load BASE/1.0 ${GCC_TOOLCHAIN_ROOT:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION} ${ROOT_VERSION:+ROOT/$ROOT_VERSION-$ROOT_REVISION}
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
# Our environment
set HEPMC3_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$HEPMC3_ROOT/bin
prepend-path LD_LIBRARY_PATH \$HEPMC3_ROOT/lib
prepend-path ROOT_INCLUDE_PATH \$HEPMC3_ROOT/include
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(HEPMC3_ROOT)/lib")
EoF
