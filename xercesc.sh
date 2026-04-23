package: XercesC
version: v3.3.0
source: https://github.com/apache/xerces-c
build_requires:
  - GCC-Toolchain
  - alibuild-recipe-tools
env:
  XERCESC_INST_DIR: "$XERCESC_ROOT"
  XERCESCINST: "$XERCESC_ROOT"
  XERCESCROOT: "$XERCESC_ROOT"
prefer_system: .*
prefer_system_check: |
  #!/bin/bash -e
  XERCESC_ROOT_EFF=${XERCESC_ROOT:-${CMAKE_PREFIX_PATH%%:*}}
  ls $XERCESC_ROOT_EFF/bin > /dev/null && \
  ls $XERCESC_ROOT_EFF/include/xercesc/ > /dev/null && \
  ls $XERCESC_ROOT_EFF/lib/libxerces-c.so > /dev/null
---
#!/bin/bash -e
(cd "$SOURCEDIR" || exit; autoreconf -i) || exit
echo "command $SOURCEDIR configure --prefix $INSTALLROOT CFLAGS $CFLAGS CXXFLAGS=$CFLAGS"
$SOURCEDIR/configure --prefix=$INSTALLROOT CFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS"
make ${JOBS+-j $JOBS}
make install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv XERCESCROOT \$PKG_ROOT
setenv XERCESC_INST_DIR \$PKG_ROOT
setenv XERCESCINST \$PKG_ROOT
EoF
