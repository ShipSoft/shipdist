package: ControlHost
version: "7cd37ac78e3e5d2974ee592b8db7de255ca2c621"
source: https://gitlab.cern.ch/olantwin/ControlHost
build_requires:
 - "GCC-Toolchain:(?!osx)"
---
#!/bin/sh
set -ex
cd "$SOURCEDIR"/src || exit -1
export INSTALL_PATH=$INSTALLROOT

make bin
make ${JOBS+-j $JOBS}
LIB=SHARED make ${JOBS+-j $JOBS}
make install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "SHiP Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "SHiP Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 ${GCC_TOOLCHAIN_ROOT:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
setenv CONTHOST_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(CONTHOST_ROOT)/lib
prepend-path PATH \$::env(CONTHOST_ROOT)/bin
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(CONTHOST_ROOT)/lib")
EoF
