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
  - "GCC-Toolchain:(?!osx)"
build_requires:
  - FairCMakeModules
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

case $ARCHITECTURE in
  osx*)
    # If we preferred system tools, we need to make sure we can pick them up.
    [[ ! $YAML_CPP_ROOT ]] && YAML_CPP_ROOT=`brew --prefix yaml-cpp`
    [[ ! $BOOST_ROOT ]] && BOOST_ROOT=`brew --prefix boost`
    [[ ! $GSL_ROOT ]] && GSL_ROOT=`brew --prefix gsl`
    MACOSX_RPATH=OFF
    SONAME=dylib
  ;;
  *) SONAME=so ;;
esac

[[ $BOOST_ROOT ]] && BOOST_NO_SYSTEM_PATHS=ON || BOOST_NO_SYSTEM_PATHS=OFF
cmake $SOURCEDIR                                                                            \
      ${CMAKE_GENERATOR:+-G "$CMAKE_GENERATOR"}                                             \
      ${MACOSX_RPATH:+-DMACOSX_RPATH=${MACOSX_RPATH}}                                       \
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
module load BASE/1.0                                                                            \\
            ${YAML_CPP_REVISION:+yaml-cpp/$YAML_CPP_VERSION-$YAML_CPP_REVISION}                  \\
            ${FAIRLOGGER_REVISION:+FairLogger/$FAIRLOGGER_VERSION-$FAIRLOGGER_REVISION}         \\
            ${GEANT3_REVISION:+GEANT3/$GEANT3_VERSION-$GEANT3_REVISION}                         \\
            ${GEANT4_VMC_REVISION:+GEANT4_VMC/$GEANT4_VMC_VERSION-$GEANT4_VMC_REVISION}         \\
            ${PYTHIA6_REVISION:+pythia6/$PYTHIA6_VERSION-$PYTHIA6_REVISION}                     \\
            ${PYTHIA_REVISION:+pythia/$PYTHIA_VERSION-$PYTHIA_REVISION}                         \\
            ${VGM_REVISION:+vgm/$VGM_VERSION-$VGM_REVISION}                                     \\
            ${BOOST_REVISION:+boost/$BOOST_VERSION-$BOOST_REVISION}                             \\
            ROOT/$ROOT_VERSION-$ROOT_REVISION                                                   \\
            ${ZEROMQ_REVISION:+ZeroMQ/$ZEROMQ_VERSION-$ZEROMQ_REVISION}                         \\
            ${GCC_TOOLCHAIN_REVISION:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
set FAIRROOT_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
set FAIRROOTPATH \$::env(BASEDIR)/$PKGNAME/\$version
setenv FAIRROOT_HASH $FAIRROOT_HASH
setenv VMCWORKDIR \$FAIRROOT_ROOT/share/fairbase/examples
setenv GEOMPATH \$::env(VMCWORKDIR)/common/geometry
setenv CONFIG_DIR \$::env(VMCWORKDIR)/common/gconfig
prepend-path PATH \$FAIRROOT_ROOT/bin
prepend-path LD_LIBRARY_PATH \$FAIRROOT_ROOT/lib
prepend-path ROOT_INCLUDE_PATH \$FAIRROOT_ROOT/include
EoF
