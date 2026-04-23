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
  ls $XERCESC_ROOT/bin > /dev/null && \
  ls $XERCESC_ROOT/include/xercesc/ > /dev/null && \
  ls $XERCESC_ROOT/lib/libxerces-c.so > /dev/null
---
#!/bin/sh
cd $SOURCEDIR
autoreconf -i
cd -
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
