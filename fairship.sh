package: FairShip
version: master
source: https://github.com/ShipSoft/FairShip
tag: master
requires:
  - generators
  - simulation
  - FairRoot
  - GENIE
  - PHOTOSPP
  - G4PY
build_requires:
  - googletest
---
#!/bin/sh

# Making sure people do not have SIMPATH set when they build fairroot.
# Unfortunately SIMPATH seems to be hardcoded in a bunch of places in
# fairroot, so this really should be cleaned up in FairRoot itself for
# maximum safety.
unset SIMPATH

case $ARCHITECTURE in
  osx*)
    # If we preferred system tools, we need to make sure we can pick them up.
    [[ ! $BOOST_ROOT ]] && BOOST_ROOT=`brew --prefix boost`
    [[ ! $ZEROMQ_ROOT ]] && ZEROMQ_ROOT=`brew --prefix zeromq`
    [[ ! $PROTOBUF_ROOT ]] && PROTOBUF_ROOT=`brew --prefix protobuf`
    [[ ! $NANOMSG_ROOT ]] && NANOMSG_ROOT=`brew --prefix nanomsg`
    [[ ! $GSL_ROOT ]] && GSL_ROOT=`brew --prefix gsl`
    SONAME=dylib
  ;;
  *) SONAME=so ;;
esac

if [[ ! -z $GEANT4_ROOT ]]
then
    source "${GEANT4_ROOT}/bin/geant4.sh"
fi

cmake $SOURCEDIR                                                 \
      -DMACOSX_RPATH=OFF                                         \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS"                              \
      -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE                       \
      -DROOTSYS=$ROOTSYS                                         \
      -DROOT_CONFIG_SEARCHPATH=$ROOT_ROOT/bin                    \
      -DPythia6_LIBRARY_DIR=$PYTHIA6_ROOT/lib                    \
      -DGeant3_DIR=$GEANT3_ROOT                                  \
      -DDISABLE_GO=ON                                            \
      -DBUILD_EXAMPLES=OFF                                       \
      ${CMAKE_VERBOSE_MAKEFILE:+-DCMAKE_VERBOSE_MAKEFILE=ON}     \
      ${DDS_ROOT:+-DDDS_PATH=$DDS_ROOT}                          \
      ${ZEROMQ_ROOT:+-DZEROMQ_ROOT=$ZEROMQ_ROOT}                 \
      ${ZEROMQ_ROOT:+-DZMQ_DIR=$ZEROMQ_ROOT}     \
      ${BOOST_ROOT:+-DBOOST_ROOT=$BOOST_ROOT}                    \
      ${BOOST_ROOT:+-DBOOST_INCLUDEDIR=$BOOST_ROOT/include}      \
      ${BOOST_ROOT:+-DBOOST_LIBRARYDIR=$BOOST_ROOT/lib}          \
      ${GSL_ROOT:+-DGSL_DIR=$GSL_ROOT}                           \
      -DGTEST_DIR=$GOOGLETEST_ROOT                              \
      -DPROTOBUF_INCLUDE_DIR=$PROTOBUF_ROOT/include              \
      -DPROTOBUF_PROTOC_EXECUTABLE=$PROTOBUF_ROOT/bin/protoc     \
      -DPROTOBUF_LIBRARY=$PROTOBUF_ROOT/lib/libprotobuf.$SONAME  \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

# Limit the number of build processes to avoid exahusting memory when building
# on smaller machines.
make -j$JOBS
make test
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
module load BASE/1.0                                                            \\
            ${GENIE_VERSION:+GENIE/$GENIE_VERSION-$GENIE_REVISION}              \\
            ${G4PY_VERSION:+G4PY/$G4PY_VERSION-$G4PY_REVISION}                  \\
            ${PHOTOSPP_VERSION:+PHOTOSPP/$PHOTOSPP_VERSION-$PHOTOSPP_REVISION}  \\
            FairRoot/$FAIRROOT_VERSION-$FAIRROOT_REVISION                       
# Our environment
setenv FAIRSHIP_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(FAIRSHIP_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(FAIRSHIP_ROOT)/lib
prepend-path ROOT_INCLUDE_PATH \$::env(FAIRSHIP_ROOT)/include
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(FAIRSHIP_ROOT)/lib")
EoF
