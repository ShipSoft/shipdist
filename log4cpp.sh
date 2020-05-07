package: log4cpp
source: https://git.code.sf.net/p/log4cpp/codegit
version: master
requires:
  - GCC-Toolchain:(?!osx)
build_requires:
  - autotools
env:
  LOG4_ROOT: "$LOG4CPP_ROOT"
---
#!/bin/bash -ex
rsync -a $SOURCEDIR/* .
./autogen.sh
./configure          --prefix=$INSTALLROOT  \
		     --enable-shared
make ${JOBS+-j$JOBS}
make install

# Modulefile support
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
module load BASE/1.0
# Our environment
setenv LOG4CPP_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(LOG4CPP_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(LOG4CPP_ROOT)/lib
EoF
