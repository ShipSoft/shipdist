package: madgraph5
version: "%(tag_basename)s%(defaults_upper)s"
source: https://github.com/DaniilSu/madgraph5
requires:
  - GCC-Toolchain
  - pythia
tag: v2.6.3.2

---
#!/bin/bash -e

echo "pythia8_path = ${PYTHIA_ROOT}" >> $SOURCEDIR/input/mg5_configuration.txt

rsync -ar $SOURCEDIR/ $INSTALLROOT/

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
module load BASE/1.0                                                   \\
	    ${PYTHIA_VERSION:+pythia/$PYTHIA_VERSION-$PYTHIA_REVISION} \\
	    lhapdf5/${LHAPDF5_VERSION}-${LHAPDF5_REVISION}
# Our environment
setenv MADGRAPH_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(MADGRAPH_ROOT)/bin
EoF
