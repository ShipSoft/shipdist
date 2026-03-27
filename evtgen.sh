package: EvtGen
version: "%(tag_basename)s-ship%(defaults_upper)s"
source: https://gitlab.cern.ch/evtgen/evtgen
tag: R02-02-03
requires:
  - HepMC3
  - pythia
  - Tauolapp
  - PHOTOSPP
env:
  EVTGENDATA: "$EVTGEN_ROOT/share/EvtGen"
prefer_system_check: |
  if [ -z "$EVTGEN_ROOT" ]; then
    for d in $(echo "$CMAKE_PREFIX_PATH" | tr : '\n'); do
      if [ -d "$d/include/EvtGen" ]; then
        export EVTGEN_ROOT="$d"
        break
      fi
    done
  fi
  ls "$EVTGEN_ROOT"/include/EvtGen > /dev/null && \
  (ls "$EVTGEN_ROOT"/lib/libEvtGen.so > /dev/null 2>&1 || \
   ls "$EVTGEN_ROOT"/lib64/libEvtGen.so > /dev/null)
---
#!/bin/sh

# Detect dependency paths from config tools when *_ROOT vars are not set
: ${PYTHIA_ROOT:=$(pythia8-config --prefix 2>/dev/null)}

rsync -a $SOURCEDIR/* .

cmake $SOURCEDIR -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DEVTGEN_HEPMC3=ON \
      ${HEPMC3_ROOT:+-DHEPMC3_ROOT_DIR=$HEPMC3_ROOT} \
      -DEVTGEN_PYTHIA=ON \
      ${PYTHIA_ROOT:+-DPYTHIA8_ROOT_DIR=$PYTHIA_ROOT} \
      -DEVTGEN_PHOTOS=ON \
      ${PHOTOSPP_ROOT:+-DPHOTOSPP_ROOT_DIR=$PHOTOSPP_ROOT} \
      -DEVTGEN_TAUOLA=ON \
      ${TAUOLAPP_ROOT:+-DTAUOLAPP_ROOT_DIR=$TAUOLAPP_ROOT}
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
module load BASE/1.0 ${PYTHIA_REVISION:+pythia/$PYTHIA_VERSION-$PYTHIA_REVISION} ${HEPMC3_REVISION:+HepMC3/$HEPMC3_VERSION-$HEPMC3_REVISION} ${TAUOLAPP_REVISION:+Tauolapp/$TAUOLAPP_VERSION-$TAUOLAPP_REVISION} ${PHOTOSPP_REVISION:+PHOTOSPP/$PHOTOSPP_VERSION-$PHOTOSPP_REVISION}
# Our environment
setenv EVTGEN_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv EVTGENDATA \$::env(EVTGEN_ROOT)/share/EvtGen
prepend-path LD_LIBRARY_PATH \$::env(EVTGEN_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(EVTGEN_ROOT)/lib")
EoF
