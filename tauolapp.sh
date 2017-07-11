package: Tauolapp
version: "%(tag_basename)s-ship%(defaults_upper)s"
source: https://github.com/PMunkes/Tauolapp
tag: v1.1.5
requires:
  - HepMC
  - ROOT
  - pythia6
  - lhapdf5
env:
  HEPMCLOCATION: "$HepMC_ROOT"
---
#!/bin/sh

$SOURCEDIR/configure --srcdir=$SOURCEDIR --with-hepmc=$HEPMC_ROOT --with-lhapdf=$LHAPDF5_ROOT --with-pythia8=$PYTHIA_ROOT --prefix=$INSTALLROOT CFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS"
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
module load BASE/1.0 ROOT/$ROOT_VERSION-$ROOT_REVISION HepMC/$HEPMC_VERSION-$HEPMC_REVISION pythia6/$PYTHIA6_VERSION-$PYTHIA6_REVISION lhapdf5/$LHAPDF5_VERSION-$LHAPDF5_REVISION
# Our environment
setenv TAUOLA_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(TAUOLA_ROOT)/lib")
EoF
