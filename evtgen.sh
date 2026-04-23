package: EvtGen
version: "%(tag_basename)s-ship%(defaults_upper)s"
tag: R02-02-03
source: https://gitlab.cern.ch/evtgen/evtgen
requires:
  - HepMC3
  - pythia
  - Tauolapp
  - PHOTOSPP
env:
  EVTGENDATA: "$EVTGEN_ROOT/share/EvtGen"
prefer_system_check: |
    if [ ! -z "$EVTGEN_VERSION" ]; then
        exit 0
    fi
    exit 1
build_requires:
  - alibuild-recipe-tools
---
#!/bin/sh

# Detect dependency paths from config tools when *_ROOT vars are not set
: "${PYTHIA_ROOT:=$(pythia8-config --prefix 2>/dev/null)}"

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
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv EVTGENDATA \$PKG_ROOT/share/EvtGen
EoF
