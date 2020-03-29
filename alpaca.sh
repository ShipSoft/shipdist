# an alpaca recipe based on pythia6.sh, phythia.sh and protobuf.sh
package: alpaca
tag: master
version: v1.1
source: https://github.com/tugberk92/alpaca
requires:
  - GCC-Toolchain:(?!osx)
env:
  ALPACABIN: "$ALPACA_ROOT/bin"
  ALPACA: "$ALPACA_ROOT"
---
#!/bin/sh
rsync -a $SOURCEDIR/* .
mkdir -p bin/{evrecs,outputs}
make
cp -r bin src doc $INSTALLROOT

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME"
# Dependencies
module load BASE/1.0
# Our environment
setenv ALPACA_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv ALPACABIN \$::env(ALPACA_ROOT)/bin
setenv ALPACA \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(ALPACA_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(ALPACA_ROOT)/obj
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(ALPACA_ROOT)/obj")
EoF
