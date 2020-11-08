package: GEANT4
version: "%(tag_basename)s%(defaults_upper)s"
source: https://github.com/alisw/geant4
tag: v4.10.01.p03
requires:
  - "GCC-Toolchain:(?!osx)"
build_requires:
  - CMake
  - "Xcode:(osx.*)"
env:
  G4INSTALL : $GEANT4_ROOT
  G4DATASEARCHOPT : "-mindepth 2 -maxdepth 4 -type d -wholename"
  G4ABLADATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4ABLA*'`"  ## v10.4.px only
  G4ENSDFSTATEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4ENSDFSTATE*'`"
  G4INCLDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4INCL*'`"  ## v10.5.px only
  G4LEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4EMLOW*'`"
  G4LEVELGAMMADATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*PhotonEvaporation*'`"
  G4NEUTRONHPDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4NDL*'`"
  G4NEUTRONXSDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4NEUTRONXS*'`"   ## v10.4.px only
  G4PARTICLEXSDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4PARTICLEXS*'`"   ## v10.5.px only
  G4PIIDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4PII*'`"
  G4RADIOACTIVEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*RadioactiveDecay*'`"
  G4REALSURFACEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*RealSurface*'`"
  G4SAIDXSDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT  '*data*G4SAIDDATA*'`"
---
#!/bin/bash -e

cmake $SOURCEDIR                                    \
  -DGEANT4_INSTALL_DATA_TIMEOUT=1500                \
  -DCMAKE_CXX_FLAGS="-fPIC"                         \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"        \
  -DCMAKE_INSTALL_LIBDIR="lib"                      \
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE              \
  -DGEANT4_BUILD_TLS_MODEL:STRING="global-dynamic"  \
  -DGEANT4_ENABLE_TESTING=OFF                       \
  -DBUILD_SHARED_LIBS=ON                            \
  -DGEANT4_INSTALL_EXAMPLES=OFF                     \
  -DCLHEP_ROOT_DIR:PATH="$CLHEP_ROOT"               \
  -DGEANT4_BUILD_MULTITHREADED=OFF                  \
  -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="-fPIC"          \
  -DCMAKE_STATIC_LIBRARY_C_FLAGS="-fPIC"            \
  -DGEANT4_USE_G3TOG4=ON                            \
  -DGEANT4_INSTALL_DATA=ON                          \
  -DGEANT4_USE_SYSTEM_EXPAT=OFF                     \
  ${XERCESC_ROOT:+-DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_GDML=ON -DXERCESC_ROOT_DIR=$XERCESC_ROOT}

make ${JOBS+-j $JOBS}
make install

ln -s lib $INSTALLROOT/lib64

#Get data file versions:
source $INSTALLROOT/bin/geant4.sh

G4DATASEARCHOPT="-mindepth 2 -maxdepth 4 -type d -wholename"
G4ABLADATA=`find ${INSTALLROOT} $G4DATASEARCHOPT '*data*G4ABLA*'`
G4ENSDFSTATEDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT '*data*G4ENSDFSTATE*'`
G4INCLDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT '*data*G4INCL*'`
G4LEDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT '*data*G4EMLOW*'`
G4LEVELGAMMADATA=`find ${INSTALLROOT} $G4DATASEARCHOPT '*data*PhotonEvaporation*'`
G4NEUTRONHPDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT '*data*G4NDL*'`
G4NEUTRONXSDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT '*data*G4NEUTRONXS*'`
G4PARTICLEXSDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT '*data*G4PARTICLEXS*'`
G4PIIDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT '*data*G4PII*'`
G4RADIOACTIVEDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT '*data*RadioactiveDecay*'`
G4REALSURFACEDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT '*data*RealSurface*'`
G4SAIDXSDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT  '*data*G4SAIDDATA*'`


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
module load BASE/1.0 ${XERCESC_ROOT:+XercesC/$XERCESC_VERSION-$XERCESC_REVISION}
# Our environment
set osname [uname sysname]
set GEANT4_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv GEANT4_ROOT \$GEANT4_ROOT
setenv G4INSTALL \$GEANT4_ROOT
setenv G4INSTALL_DATA \$GEANT4_ROOT/share/
setenv G4SYSTEM \$osname-g++
setenv G4ABLADATA ${G4ABLADATA:-not-defined}
setenv G4ENSDFSTATEDATA ${G4ENSDFSTATEDATA:-not-defined}
setenv G4INCLDATA ${G4INCLDATA:-not-defined}
setenv G4LEDATA ${G4LEDATA:-not-defined}
setenv G4LEVELGAMMADATA ${G4LEVELGAMMADATA:-not-defined}
setenv G4NEUTRONHPDATA ${G4NEUTRONHPDATA:-not-defined}
setenv G4NEUTRONXSDATA ${G4NEUTRONXSDATA:-not-defined}
setenv G4PARTICLEXSDATA ${G4PARTICLEXSDATA:-not-defined}
setenv G4PIIDATA ${G4PIIDATA:-not-defined}
setenv G4RADIOACTIVEDATA  ${G4RADIOACTIVEDATA:-not-defined}
setenv G4REALSURFACEDATA ${G4REALSURFACEDATA:-not-defined}
setenv G4SAIDXSDATA ${G4SAIDXSDATA:-not-defined}
set G4BASE \$GEANT4_ROOT
prepend-path PATH \$GEANT4_ROOT/bin
prepend-path ROOT_INCLUDE_PATH \$GEANT4_ROOT/include/Geant4
prepend-path ROOT_INCLUDE_PATH \$GEANT4_ROOT/include
prepend-path LD_LIBRARY_PATH \$GEANT4_ROOT/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(GEANT4_ROOT)/lib")
EoF
