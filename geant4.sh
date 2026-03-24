package: GEANT4
version: "%(tag_basename)s"
tag: v11.4.0
source: https://github.com/geant4/geant4.git
requires:
  - GCC-Toolchain
  - opengl
  - XercesC
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
env:
  G4INSTALL: $GEANT4_ROOT
  G4DATASEARCHOPT: "-mindepth 2 -maxdepth 4 -type d -wholename"
  G4ABLADATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4ABLA*'`"  ## v10.4.px only
  G4ENSDFSTATEDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4ENSDFSTATE*'`"
  G4INCLDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4INCL*'`"  ## v10.5.px only
  G4LEDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4EMLOW*'`"
  G4LEVELGAMMADATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*PhotonEvaporation*'`"
  G4NEUTRONHPDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4NDL*'`"
  G4NEUTRONXSDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4NEUTRONXS*'`"   ## v10.4.px only
  G4PARTICLEXSDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4PARTICLEXS*'`"   ## v10.5.px only
  G4PIIDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4PII*'`"
  G4RADIOACTIVEDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*RadioactiveDecay*'`"
  G4REALSURFACEDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*RealSurface*'`"
  G4SAIDXSDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT  '*data*G4SAIDDATA*'`"
prefer_system_check: |
  #!/bin/bash -e
  ls $GEANT4_ROOT/bin > /dev/null && \
  ls $GEANT4_ROOT/bin/geant4-config > /dev/null && \
  ls $GEANT4_ROOT/bin/geant4.csh > /dev/null && \
  ls $GEANT4_ROOT/bin/geant4.sh > /dev/null && \
  ls $GEANT4_ROOT/include > /dev/null && \
  ls $GEANT4_ROOT/include/Geant4 > /dev/null && \
  ls $GEANT4_ROOT/lib/ > /dev/null && \
  true
---
#!/bin/bash -e
export G4DEBUG=1
cmake $SOURCEDIR                                    \
  -G Ninja \
  -DGEANT4_INSTALL_DATA_TIMEOUT=1500                \
  -DCMAKE_CXX_FLAGS="-fPIC"                         \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"        \
  -DCMAKE_INSTALL_LIBDIR="lib"                      \
  -DCMAKE_BUILD_TYPE="DEBUG"              \
  -DGEANT4_BUILD_TLS_MODEL:STRING="global-dynamic"  \
  -DGEANT4_ENABLE_TESTING=OFF                       \
  -DBUILD_SHARED_LIBS=ON                            \
  -DG4VERBOSE=ON                                    \
  -DGEANT4_INSTALL_EXAMPLES=OFF                     \
  -DGEANT4_BUILD_MULTITHREADED=OFF                  \
  -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="-fPIC"          \
  -DCMAKE_STATIC_LIBRARY_C_FLAGS="-fPIC"            \
  -DGEANT4_USE_G3TOG4=ON                            \
  -DGEANT4_INSTALL_DATA=ON                          \
  -DGEANT4_USE_SYSTEM_EXPAT=OFF                     \
  ${XERCESC_ROOT:+-DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_GDML=ON -DXERCESC_ROOT_DIR=$XERCESC_ROOT}

cmake --build . ${JOBS+-j$JOBS} --target install

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
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv G4INSTALL \$PKG_ROOT
setenv G4INSTALL_DATA \$PKG_ROOT/share/
set osname [uname sysname]
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
setenv G4RADIOACTIVEDATA ${G4RADIOACTIVEDATA:-not-defined}
setenv G4REALSURFACEDATA ${G4REALSURFACEDATA:-not-defined}
setenv G4SAIDXSDATA ${G4SAIDXSDATA:-not-defined}
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include/Geant4
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
EoF
