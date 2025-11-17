package: EvtGen
version: "%(tag_basename)s-ship%(defaults_upper)s"
source: https://github.com/alisw/EVTGEN/ # https://github.com/ShipSoft/evtgen
tag: R02-02-00-alice2
requires:
  - HepMC
  - pythia
  - Tauolapp
  - PHOTOSPP
env:
  EVTGENDATA: "$EVTGEN_ROOT/share/EvtGen"
---
#!/bin/sh

export  HEPMCLOCATION="$HEPMC_ROOT"

rsync -a $SOURCEDIR/* .

cmake $SOURCEDIR -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DEVTGEN_HEPMC3=OFF \
      -DHEPMC2_ROOT_DIR=$HEPMC_ROOT \
      -DEVTGEN_PYTHIA=ON \
      -DPYTHIA8_ROOT_DIR=$PYTHIA_ROOT \
      -DEVTGEN_PHOTOS=ON \
      -DPHOTOSPP_ROOT_DIR=$PHOTOSPP_ROOT \
      -DEVTGEN_TAUOLA=ON \
      -DTAUOLAPP_ROOT_DIR=$TAUOLAPP_ROOT
make ${JOBS:+-j$JOBS} install

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
module load BASE/1.0 pythia/$PYTHIA_VERSION-$PYTHIA_REVISION HepMC/$HEPMC_VERSION-$HEPMC_REVISION  Tauolapp/$TAUOLAPP_VERSION-$TAUOLAPP_REVISION PHOTOSPP/$PHOTOSPP_VERSION-$PHOTOSPP_REVISION
# Our environment
setenv EVTGEN_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv EVTGENDATA \$::env(EVTGEN_ROOT)/share/EvtGen
prepend-path LD_LIBRARY_PATH \$::env(EVTGEN_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(EVTGEN_ROOT)/lib")
EoF
