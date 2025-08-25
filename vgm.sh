package: vgm
version: "%(tag_basename)s%(defaults_upper)s"
tag: "v5-3-1"
source: https://github.com/vmc-project/vgm.git
requires:
  - ROOT
  - GEANT4
  - XercesC
build_requires:
  - CMake
---
Geant4_DIR=/cvmfs/sft.cern.ch/lcg/releases/Geant4/11.2.0-52c79/x86_64-el9-gcc12-opt/lib64/cmake/Geant4/
#!/bin/bash -e
cmake "$SOURCEDIR" \
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
  -DCMAKE_INSTALL_LIBDIR="lib"           \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"  \
  -DWITH_EXAMPLES=OFF                \
  -DWITH_TEST=OFF                     \
  -DBUILD_SHARED_LIBS=OFF \
  -DGeant4_DIR=/cvmfs/sft.cern.ch/lcg/releases/Geant4/11.2.0-52c79/x86_64-el9-gcc12-opt/lib64/cmake/Geant4/ \
  -DCLHEP_DIR=/cvmfs/sft.cern.ch/lcg/releases/clhep/2.4.7.1-b7a7d/x86_64-el9-gcc12-opt/

Geant4_DIR=/cvmfs/sft.cern.ch/lcg/releases/Geant4/11.2.0-52c79/x86_64-el9-gcc12-opt/lib64/Geant4-11.2.0/Linux-g++/cmake/Geant4/
make ${JOBS+-j $JOBS} install

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
module load BASE/1.0 GEANT4/$GEANT4_VERSION-$GEANT4_REVISION ROOT/$ROOT_VERSION-$ROOT_REVISION
# Our environment
setenv VGM_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(VGM_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(VGM_ROOT)/lib")
EoF
