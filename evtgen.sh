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
prefer_system_check: |
    if [ ! -z "$EVTGEN_VERSION" ]; then
        exit 0
    fi
    exit 1
build_requires:
  - alibuild-recipe-tools
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
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv EVTGENDATA \$PKG_ROOT/share/EvtGen
EoF
