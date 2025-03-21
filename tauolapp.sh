package: Tauolapp
version: "%(tag_basename)s-ship%(defaults_upper)s"
source: https://github.com/ShipSoft/Tauolapp
tag: v1.1.5
requires:
  - HepMC
  - ROOT
  - pythia
  - lhapdf
---
#!/bin/sh

export  HEPMCLOCATION="$HEPMC_ROOT"

rsync -a $SOURCEDIR/* .

./configure --with-hepmc=$HEPMC_ROOT --with-lhapdf=$LHAPDF_ROOT --with-pythia8=$PYTHIA_ROOT --prefix=$INSTALLROOT CFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS"

make
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
module load BASE/1.0 ROOT/$ROOT_VERSION-$ROOT_REVISION pythia/$PYTHIA_VERSION-$PYTHIA_REVISION HepMC/$HEPMC_VERSION-$HEPMC_REVISION lhapdf/$LHAPDF_VERSION-$LHAPDF_REVISION
# Our environment
setenv TAUOLA_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(TAUOLA_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(TAUOLA_ROOT)/lib")
EoF

cat $MODULEFILE
