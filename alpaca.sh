# a pythia6 recipe based on the one from FairROOT
package: alpaca
tag: master
version: v1.1
source: https://github.com/tugberk92/alpaca
requires:
  - GCC-Toolchain:(?!osx)
---
#!/bin/sh
rsync -a $SOURCEDIR/* .
make

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
module-whatis "ALICE Modulefile for $PKGNAME"
# Dependencies
module load BASE/1.0
EoF
