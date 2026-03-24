package: GEANT4_VMC
version: "%(tag_basename)s"
tag: "v6-7"
source: https://github.com/vmc-project/geant4_vmc
requires:
  - ROOT
  - VMC
  - GEANT4
  - vgm
build_requires:
  - CMake
  - "Xcode:(osx.*)"
  - alibuild-recipe-tools
prepend_path:
  ROOT_INCLUDE_PATH: "$GEANT4_VMC_ROOT/include/g4root:$GEANT4_VMC_ROOT/include/geant4vmc:$GEANT4_VMC_ROOT/include/mtroot"
env:
  G4VMCINSTALL: "$GEANT4_VMC_ROOT"
prefer_system_check: |
  #!/bin/bash -e
  ls $GEANT4_VMC_ROOT/bin > /dev/null && \
  ls $GEANT4_VMC_ROOT/lib/libg4root.so > /dev/null && \
  ls $GEANT4_VMC_ROOT/lib/libgeant4vmc.so> /dev/null && \
  ls $GEANT4_VMC_ROOT/include/g4root > /dev/null && \
  ls $GEANT4_VMC_ROOT/include/geant4vmc > /dev/null && \
  true
---
#!/bin/bash -e
LDFLAGS="$LDFLAGS -L$GEANT4_ROOT/lib"            \
  cmake "$SOURCEDIR"                             \
    -DCMAKE_CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DGeant4VMC_USE_VGM=ON                       \
    -DCMAKE_INSTALL_LIBDIR=lib                   \
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"        \
    -DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
    ${XERCESC_ROOT:+-DXercesC_ROOT=$XERCESC_ROOT} \
    ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}

make ${JOBS+-j $JOBS} install
G4VMC_SHARE=$(cd "$INSTALLROOT/share"; echo Geant4VMC-* | cut -d' ' -f1)
ln -nfs "$G4VMC_SHARE/examples" "$INSTALLROOT/share/examples"

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv G4VMCINSTALL \$PKG_ROOT
setenv GEANT4VMC_MACRO_DIR \$PKG_ROOT/share/examples/macro
setenv USE_VGM 1
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include/mtroot
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include/geant4vmc
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include/g4root
EoF
