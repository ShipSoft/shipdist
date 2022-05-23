package: apfel
version: 3.0.6
tag: 3.0.6
source: https://github.com/scarrazza/apfel.git
requires:
  - lhapdf
env :
  LD_LIBRARY_PATH: "$LD_LIBRARY_PATH:$APFEL_ROOT/lib"
---
#!/bin/bash -ex

rsync -a $SOURCEDIR/* $BUILDDIR

$BUILDDIR/configure --prefix=${INSTALLROOT}

make
make install

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
module load BASE/1.0
# Environment
setenv APFEL_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(APFEL_ROOT)/lib
EoF
