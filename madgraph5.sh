package: madgraph5
version: "%(tag_basename)s%(defaults_upper)s"
source: https://github.com/shir994/madgraph5
requires:
  - GCC-Toolchain
  - pythia
tag: master

---
#!/bin/bash -e

curl -O -L https://launchpad.net/mg5amcnlo/2.0/2.6.x/+download/MG5_aMC_v2.6.1.tar.gz
tar -xf MG5_aMC_v2.6.1.tar.gz -C ./ --strip 1

echo "pythia8_path = ${PYTHIA_ROOT}" >> ./input/mg5_configuration.txt

rsync -ar $BUILDDIR/ $INSTALLROOT/

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
