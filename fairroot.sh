package: FairRoot
version: "v19.0.0"
tag: "v19.0.0"
source: https://github.com/FairRootGroup/FairRoot
requires:
  - pythia
  - pythia6
  - EvtGen
  - GEANT4_VMC
  - GEANT4
  - HepMC
  - ROOT
  - VMC
  - boost
  - FairLogger
  - yaml-cpp
  - GEANT3
  - GCC-Toolchain
build_requires:
  - FairCMakeModules
  - alibuild-recipe-tools
env:
  VMCWORKDIR: "$FAIRROOT_ROOT/share/fairbase/examples"
  GEOMPATH:   "$FAIRROOT_ROOT/share/fairbase/examples/common/geometry"
  CONFIG_DIR: "$FAIRROOT_ROOT/share/fairbase/examples/common/gconfig"
  FAIRROOTPATH: "$FAIRROOT_ROOT"
prefer_system_check: |
  ls $FAIRROOT_ROOT/ > /dev/null && \
  ls $FAIRROOT_ROOT/lib > /dev/null && \
  ls $FAIRROOT_ROOT/include > /dev/null
prepend_path:
  ROOT_INCLUDE_PATH: "$FAIRROOT_ROOT/include"
  LD_LIBRARY_PATH: "$FAIRROOT_ROOT/lib"
---
# Making sure people do not have SIMPATH set when they build fairroot.
# Unfortunately SIMPATH seems to be hardcoded in a bunch of places in
# fairroot, so this really should be cleaned up in FairRoot itself for
# maximum safety.
unset SIMPATH

[[ $BOOST_ROOT ]] && BOOST_NO_SYSTEM_PATHS=ON || BOOST_NO_SYSTEM_PATHS=OFF
cmake $SOURCEDIR                                                                            \
      ${CMAKE_GENERATOR:+-G "$CMAKE_GENERATOR"}                                             \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS"                                                         \
      -DCMAKE_CATCH_DISCOVER_TESTS_DISCOVERY_MODE=PRE_TEST                                   \
      ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE}                             \
      -DROOTSYS=$ROOTSYS                                                                    \
      -DPythia6_LIBRARY_DIR=$PYTHIA6_ROOT/lib                                               \
      ${YAML_CPP_ROOT:+-DYAML_CPP_ROOT=$YAML_CPP_ROOT}                                      \
      -DGeant3_DIR=$GEANT3_ROOT                                                             \
      -DBUILD_EXAMPLES=ON                                                                   \
      ${GEANT4_ROOT:+-DGeant4_DIR=$GEANT4_ROOT}                                             \
      ${GEANT4_VMC_ROOT:+-DGeant4VMC_ROOT=$GEANT4_VMC_ROOT} \
      ${XERCESC_ROOT:+-DXercesC_ROOT=$XERCESC_ROOT} \
      ${BOOST_ROOT:+-DBOOST_ROOT=$BOOST_ROOT}                                               \
      -DBoost_NO_SYSTEM_PATHS=${BOOST_NO_SYSTEM_PATHS}                                      \
      ${GSL_ROOT:+-DGSL_DIR=$GSL_ROOT}                                                      \
      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                                               \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                                                    \
      -DCMAKE_INSTALL_LIBDIR=lib                                                            \
      -DCMAKE_POLICY_DEFAULT_CMP0167=NEW \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      -DFairCMakeModules_ROOT=$FAIRCMAKEMODULES_ROOT \
      -DBUILD_BASEMQ=OFF

cmake --build . -- -j$JOBS install

# Work around hardcoded paths in PCM
for DIR in source sink field event sim steer; do
  ln -nfs ../include $INSTALLROOT/include/$DIR
done

#Get current git hash, needed by FairShip
cd $SOURCEDIR
FAIRROOT_HASH=$(git rev-parse HEAD)
cd $BUILDDIR

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv FAIRROOT_HASH $FAIRROOT_HASH
setenv VMCWORKDIR \$PKG_ROOT/share/fairbase/examples
setenv GEOMPATH \$::env(VMCWORKDIR)/common/geometry
setenv CONFIG_DIR \$::env(VMCWORKDIR)/common/gconfig
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
EoF
