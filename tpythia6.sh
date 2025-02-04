package: TPythia6
version: "main"
tag: "main"
source: https://github.com/ShipSoft/TPythia6
requires:
  - ROOT
  - pythia6
build_requires:
  - CMake
prepend_path:
  ROOT_INCLUDE_PATH: "$TPYTHIA6_ROOT/inc"
---
#!/bin/bash -e
cmake "$SOURCEDIR"                               \
    -DPYTHIA6_ROOT=${PYTHIA6_ROOT} \

make 
cp -r $SOURCEDIR/inc $INSTALLROOT/inc
cp *.so $INSTALLROOT/
cp *.pcm $INSTALLROOT/
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
# Our environment
set TPYTHIA6_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv TPYTHIA6_ROOT \$TPYTHIA6_ROOT
prepend-path ROOT_INCLUDE_PATH \$TPYTHIA6_ROOT/inc
prepend-path LD_LIBRARY_PATH \$TPYTHIA6_ROOT
EoF
