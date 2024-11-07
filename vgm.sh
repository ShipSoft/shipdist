package: vgm
version: "%(tag_basename)s%(defaults_upper)s"
tag: "v5-2"
source: https://github.com/vmc-project/vgm.git
requires:
  - ROOT
  - GEANT4
  - XercesC
build_requires:
  - CMake
prefer_system_check: |
  ls $VGM_ROOT/ > /dev/null && \
  ls $VGM_ROOT/include > /dev/null && \
  ls $VGM_ROOT/include/BaseVGM > /dev/null && \
  ls $VGM_ROOT/include/ClhepVGM > /dev/null && \
  ls $VGM_ROOT/include/Geant4GM > /dev/null && \
  ls $VGM_ROOT/include/RootGM > /dev/null && \
  ls $VGM_ROOT/include/VGM > /dev/null && \
  ls $VGM_ROOT/include/XmlVGM > /dev/null && \
  ls $VGM_ROOT/lib > /dev/null && \
  ls $VGM_ROOT/lib/libBaseVGM.a > /dev/null && \
  ls $VGM_ROOT/lib/libClhepVGM.a > /dev/null && \
  ls $VGM_ROOT/lib/libGeant4GM.a > /dev/null && \
  ls $VGM_ROOT/lib/libRootGM.a > /dev/null && \
  ls $VGM_ROOT/lib/libXmlVGM.a > /dev/null
---
#!/bin/bash -e
cmake "$SOURCEDIR" \
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
  -DCMAKE_INSTALL_LIBDIR="lib"           \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"  \
  -DWITH_EXAMPLES=OFF                \
  -DWITH_TEST=OFF                     \
  -DBUILD_SHARED_LIBS=OFF

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
