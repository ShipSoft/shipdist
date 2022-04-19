package: GENIE_HEDIS_SF
version: v1
requires :
  - GENIE
---
#/bin/bash -ex

# TEMP TEMP TEMP. REMOVE.
export LHAPATH=/afs/cern.ch/work/c/cvilela/private/snd_genie_integration/lhapdftemp/

# This needs write access to $GENIE_ROOT/genie/data/ so run it during build. Very annoying.
gmkhedissf --tune GHE19_00b_00_000
mkdir -p $GENIE_ROOT/genie/data/evgen/photon-sf/
gmkphotonsf --tune GHE19_00b_00_000

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
EoF
