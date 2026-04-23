package: FairShip
version: master
tag: master
source: https://github.com/ShipSoft/FairShip
requires:
  - pythia
  - pythia6
  - GEANT4_VMC
  - HepMC
  - FairRoot
  - FairLogger
  - GENIE
  - GenFit
  - GEANT4
  - PHOTOSPP
  - EvtGen
  - ROOT
  - ROOTEGPythia6
  - VMC
  - python-matplotlib
  - python-pandas
  - python-pyyaml
  - python-scipy
  - python-tabulate
  - python-uproot
  - HepMC3
  - acts
build_requires:
  - FairCMakeModules
  - alibuild-recipe-tools
  - ninja
env:
  FAIRSHIP: "$FAIRSHIP_ROOT"
  EOSSHIP: "root://eospublic.cern.ch/"
  VMCWORKDIR: "$FAIRSHIP_ROOT"
  GEOMPATH: "$FAIRSHIP_ROOT/geometry"
  CONFIG_DIR: "$FAIRSHIP_ROOT/gconfig"
  GALCONF: "$FAIRSHIP_ROOT/shipgen/genie_config"
  FAIRLIBDIR: "$FAIRSHIP_ROOT/lib"
prepend_path:
  PYTHONPATH: "$FAIRSHIP_ROOT/python"
  ROOT_INCLUDE_PATH: "$FAIRSHIP_ROOT/include"
  LD_LIBRARY_PATH: "$FAIRSHIP_ROOT/lib"
append_path:
  ROOT_INCLUDE_PATH:
    - "$GEANT4_ROOT/include"
    - "$GEANT4_ROOT/include/Geant4"
    - "$PYTHIA_ROOT/include"
    - "$PYTHIA_ROOT/include/Pythia8"
    - "$GEANT4_VMC_ROOT/include"
    - "$GEANT4_VMC_ROOT/include/geant4vmc"
incremental_recipe: |
  #!/bin/bash -e
  rsync -ar $SOURCEDIR/ $INSTALLROOT/
  cmake --build . ${JOBS+-j$JOBS} --target install
  #Get the current git hash
  cd $SOURCEDIR
  FAIRSHIP_HASH=$(git rev-parse HEAD)
  cd $BUILDDIR
  # Modulefile
  mkdir -p "$INSTALLROOT/etc/modulefiles"
  alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
  cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
  setenv FAIRSHIP_HASH $FAIRSHIP_HASH
  setenv FAIRSHIP \$PKG_ROOT
  setenv FAIRSHIP_ROOT \$PKG_ROOT
  setenv EOSSHIP root://eospublic.cern.ch/
  setenv VMCWORKDIR \$PKG_ROOT
  setenv GEOMPATH \$PKG_ROOT/geometry
  setenv CONFIG_DIR \$PKG_ROOT/gconfig
  setenv GALCONF \$PKG_ROOT/shipgen/genie_config
  setenv FAIRLIBDIR \$PKG_ROOT/lib
  prepend-path PYTHONPATH \$PKG_ROOT/python
  prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
  append-path ROOT_INCLUDE_PATH $GEANT4_ROOT/include
  append-path ROOT_INCLUDE_PATH $GEANT4_ROOT/include/Geant4
  append-path ROOT_INCLUDE_PATH $PYTHIA_ROOT/include
  append-path ROOT_INCLUDE_PATH $PYTHIA_ROOT/include/Pythia8
  append-path ROOT_INCLUDE_PATH $GEANT4_VMC_ROOT/include
  append-path ROOT_INCLUDE_PATH $GEANT4_VMC_ROOT/include/geant4vmc
  EoF
---
#!/bin/bash -e

rsync -a $SOURCEDIR/ $INSTALLROOT/

cmake $SOURCEDIR                                                 \
      -G Ninja \
      -DFAIRBASE="$FAIRROOT_ROOT/share/fairbase"                 \
      -DFAIRROOTPATH="$FAIRROOTPATH"                             \
      -DFAIRROOT_INCLUDE_DIR="$FAIRROOT_ROOT/include"            \
      -DFAIRROOT_LIBRARY_DIR="$FAIRROOT_ROOT/lib"                \
      -DFMT_INCLUDE_DIR="$FMT_ROOT/include"                      \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS"                              \
      -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE                       \
      -DROOT_DIR=$ROOT_ROOT                                      \
      -DROOTEGPythia6_ROOT=$ROOTEGPYTHIA6_ROOT                   \
      -DHEPMC_DIR=$HEPMC_ROOT                                    \
      -DHEPMC_INCLUDE_DIR=$HEPMC_ROOT/include/HepMC              \
      -DEVTGEN_INCLUDE_DIR=$EVTGEN_ROOT/include                  \
      -DEVTGEN_LIBRARY_DIR=$EVTGEN_ROOT/lib                      \
      -DPYTHIA8_DIR=$PYTHIA_ROOT                                 \
      -DPYTHIA8_INCLUDE_DIR=$PYTHIA_ROOT/include                 \
      -DGEANT4_ROOT=$GEANT4_ROOT                                 \
      -DGEANT4_INCLUDE_DIR=$GEANT4_ROOT/include/Geant4           \
      -DGEANT4_VMC_INCLUDE_DIR=$GEANT4_VMC_ROOT/include/geant4vmc \
      ${CMAKE_VERBOSE_MAKEFILE:+-DCMAKE_VERBOSE_MAKEFILE=ON}     \
      -DFairCMakeModules_ROOT=$FAIRCMAKEMODULES_ROOT \
      ${GENFIT_ROOT:+-Dgenfit2_ROOT=$GENFIT_ROOT} \
      ${ACTS:+-DACTS_ROOT=$ACTS_ROOT} \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

cmake --build . ${JOBS+-j$JOBS} --target install

#Get the current git hash
cd $SOURCEDIR
FAIRSHIP_HASH=$(git rev-parse HEAD)
cd $BUILDDIR

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv FAIRSHIP_HASH $FAIRSHIP_HASH
setenv FAIRSHIP \$PKG_ROOT
setenv FAIRSHIP_ROOT \$PKG_ROOT
setenv EOSSHIP root://eospublic.cern.ch/
setenv VMCWORKDIR \$PKG_ROOT
setenv GEOMPATH \$PKG_ROOT/geometry
setenv CONFIG_DIR \$PKG_ROOT/gconfig
setenv GALCONF \$PKG_ROOT/shipgen/genie_config
setenv FAIRLIBDIR \$PKG_ROOT/lib
prepend-path PYTHONPATH \$PKG_ROOT/python
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
append-path ROOT_INCLUDE_PATH $GEANT4_ROOT/include
append-path ROOT_INCLUDE_PATH $GEANT4_ROOT/include/Geant4
append-path ROOT_INCLUDE_PATH $PYTHIA_ROOT/include
append-path ROOT_INCLUDE_PATH $PYTHIA_ROOT/include/Pythia8
append-path ROOT_INCLUDE_PATH $GEANT4_VMC_ROOT/include
append-path ROOT_INCLUDE_PATH $GEANT4_VMC_ROOT/include/geant4vmc
EoF
