package: FairShip
version: master
source: https://github.com/ShipSoft/FairShip
tag: master
requires:
  - generators
  - simulation
  - FairRoot
  - FairLogger
  - GENIE
  - GenFit
  - GEANT4
  - PHOTOSPP
  - EvtGen
  - ROOT
  - VMC
  - TPythia6
incremental_recipe: |
  rsync -ar $SOURCEDIR/ $INSTALLROOT/
  cmake --build . ${JOBS+-j$JOBS} --target install
  #Get the current git hash
  cd $SOURCEDIR
  FAIRSHIP_HASH=$(git rev-parse HEAD)
  cd $BUILDDIR
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
  module load BASE/1.0                                                          \\
            ${GEANT4_VERSION:+GEANT4/$GEANT4_VERSION-$GEANT4_REVISION}          \\
            ${GENIE_VERSION:+GENIE/$GENIE_VERSION-$GENIE_REVISION}              \\
            ${PHOTOSPP_VERSION:+PHOTOSPP/$PHOTOSPP_VERSION-$PHOTOSPP_REVISION}  \\
            ${EVTGEN_VERSION:+EvtGen/$EVTGEN_VERSION-$EVTGEN_REVISION}          \\
            ${FAIRROOT_VERSION:+FairRoot/$FAIRROOT_VERSION-$FAIRROOT_REVISION} \\
            ${GENFIT_VERSION:+GenFit/$GENFIT_VERSION-$GENFIT_REVISION}         \\
            ${TPYTHIA6_VERSION:+TPythia6/$TPYTHIA6_VERSION-$TPYTHIA6_REVISION}
  # Our environment
  setenv EOSSHIP root://eospublic.cern.ch/
  setenv FAIRSHIP_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
  setenv FAIRSHIP \$::env(FAIRSHIP_ROOT)
  setenv FAIRSHIP_HASH $FAIRSHIP_HASH
  setenv VMCWORKDIR \$::env(FAIRSHIP)
  setenv GEOMPATH \$::env(FAIRSHIP)/geometry
  setenv CONFIG_DIR \$::env(FAIRSHIP)/gconfig
  setenv GALGCONF \$::env(FAIRSHIP_ROOT)/shipgen/genie_config
  prepend-path PATH \$::env(FAIRSHIP_ROOT)/bin
  prepend-path LD_LIBRARY_PATH \$::env(FAIRSHIP_ROOT)/lib
  setenv FAIRLIBDIR \$::env(FAIRSHIP_ROOT)/lib
  prepend-path ROOT_INCLUDE_PATH \$::env(FAIRSHIP_ROOT)/include
  append-path ROOT_INCLUDE_PATH \$::env(GEANT4_ROOT)/include
  append-path ROOT_INCLUDE_PATH \$::env(GEANT4_ROOT)/include/Geant4
  append-path ROOT_INCLUDE_PATH \$::env(PYTHIA_ROOT)/include
  append-path ROOT_INCLUDE_PATH \$::env(PYTHIA_ROOT)/include/Pythia8
  append-path ROOT_INCLUDE_PATH \$::env(GEANT4_VMC_ROOT)/include
  append-path ROOT_INCLUDE_PATH \$::env(GEANT4_VMC_ROOT)/include/geant4vmc
  append-path ROOT_INCLUDE_PATH \$::env(TPYTHIA6_ROOT)/inc
  prepend-path PYTHONPATH \$::env(FAIRSHIP_ROOT)/python
  EoF
---
#!/bin/sh

rsync -a $SOURCEDIR/ $INSTALLROOT/

cmake $SOURCEDIR                                                 \
      -DFAIRBASE="$FAIRROOT_ROOT/share/fairbase"                 \
      -DFAIRROOTPATH="$FAIRROOTPATH"                             \
      -DFAIRROOT_INCLUDE_DIR="$FAIRROOT_ROOT/include"            \
      -DFAIRROOT_LIBRARY_DIR="$FAIRROOT_ROOT/lib"                \
      -DFMT_INCLUDE_DIR="$FMT_ROOT/include"                      \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS"                              \
      -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE                       \
      -DROOT_DIR=$ROOT_ROOT                                      \
      -DHEPMC_DIR=$HEPMC_ROOT                                    \
      -DHEPMC_INCLUDE_DIR=$HEPMC_ROOT/include/HepMC              \
      -DEVTGEN_INCLUDE_DIR=$EVTGEN_ROOT/include                  \
      -DEVTGEN_LIBRARY_DIR=$EVTGEN_ROOT/lib                      \
      ${PYTHON_ROOT:+-DPYTHON_LIBRARY=$PYTHON_ROOT/lib}          \
      ${PYTHON_ROOT:+-DPYTHON_INCLUDE_DIR=$PYTHON_ROOT/include/python3.6m/} \
      -DPYTHIA8_DIR=$PYTHIA_ROOT                                 \
      -DPYTHIA8_INCLUDE_DIR=$PYTHIA_ROOT/include                 \
      -DGEANT4_ROOT=$GEANT4_ROOT                                 \
      -DGEANT4_INCLUDE_DIR=$GEANT4_ROOT/include/Geant4           \
      -DGEANT4_VMC_INCLUDE_DIR=$GEANT4_VMC_ROOT/include/geant4vmc \
      ${CMAKE_VERBOSE_MAKEFILE:+-DCMAKE_VERBOSE_MAKEFILE=ON}     \
      ${BOOST_ROOT:+-DBOOST_ROOT=$BOOST_ROOT}                    \
      ${GENFIT:+-Dgenfit2_ROOT=$GENFIT} \
      -DTPYTHIA6_INCLUDE_DIR=$TPYTHIA6_ROOT/inc \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

cmake --build . ${JOBS+-j$JOBS} --target install

#Get the current git hash
cd $SOURCEDIR
FAIRSHIP_HASH=$(git rev-parse HEAD)
cd $BUILDDIR

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
module load BASE/1.0                                                            \\
            ${GEANT4_VERSION:+GEANT4/$GEANT4_VERSION-$GEANT4_REVISION}          \\
            ${GENIE_VERSION:+GENIE/$GENIE_VERSION-$GENIE_REVISION}              \\
            ${PHOTOSPP_VERSION:+PHOTOSPP/$PHOTOSPP_VERSION-$PHOTOSPP_REVISION}  \\
            ${EVTGEN_VERSION:+EvtGen/$EVTGEN_VERSION-$EVTGEN_REVISION}          \\
            ${FAIRROOT_VERSION:+FairRoot/$FAIRROOT_VERSION-$FAIRROOT_REVISION}	\\
            ${GENFIT_VERSION:+GenFit/$GENFIT_VERSION-$GENFIT_REVISION}          \\
            ${TPYTHIA6_VERSION:+TPythia6/$TPYTHIA6_VERSION-$TPYTHIA6_REVISION}
# Our environment
setenv EOSSHIP root://eospublic.cern.ch/
setenv FAIRSHIP_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv FAIRSHIP \$::env(FAIRSHIP_ROOT)
setenv FAIRSHIP_HASH $FAIRSHIP_HASH
setenv VMCWORKDIR \$::env(FAIRSHIP)
setenv GEOMPATH \$::env(FAIRSHIP)/geometry
setenv CONFIG_DIR \$::env(FAIRSHIP)/gconfig
setenv GALGCONF \$::env(FAIRSHIP_ROOT)/shipgen/genie_config
prepend-path PATH \$::env(FAIRSHIP_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(FAIRSHIP_ROOT)/lib
setenv FAIRLIBDIR \$::env(FAIRSHIP_ROOT)/lib
prepend-path ROOT_INCLUDE_PATH \$::env(FAIRSHIP_ROOT)/include
append-path ROOT_INCLUDE_PATH \$::env(GEANT4_ROOT)/include
append-path ROOT_INCLUDE_PATH \$::env(GEANT4_ROOT)/include/Geant4
append-path ROOT_INCLUDE_PATH \$::env(PYTHIA_ROOT)/include
append-path ROOT_INCLUDE_PATH \$::env(PYTHIA_ROOT)/include/Pythia8
append-path ROOT_INCLUDE_PATH \$::env(GEANT4_VMC_ROOT)/include
append-path ROOT_INCLUDE_PATH \$::env(GEANT4_VMC_ROOT)/include/geant4vmc
append-path ROOT_INCLUDE_PATH \$::env(TPYTHIA6_ROOT)/inc
prepend-path PYTHONPATH \$::env(FAIRSHIP_ROOT)/python
EoF
