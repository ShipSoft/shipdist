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
  - alibuild-recipe-tools
prefer_system_check: |
  #!/bin/bash -e
  [[ -v VGM_ROOT ]] && \
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
  ${XERCESC_ROOT:+-DXercesC_ROOT=$XERCESC_ROOT} \
  -DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
  -DCMAKE_POLICY_DEFAULT_CMP0144=NEW \
  -DBUILD_SHARED_LIBS=OFF
#  ${XERCESC_ROOT:+-DXercesC_INCLUDE_DIR=$XERCESC_ROOT/include -DXercesC_LIBRARY=$XERCESC_ROOT/lib} \

make ${JOBS+-j $JOBS} install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv VGM_ROOT \$PKG_ROOT
EoF
