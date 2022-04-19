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

# THIS IS VERY VERY HORRIBLE, JUST FOR TESTING. MAKE SURE TO REMOVE BEFORE COMMIT!!!
sed -i "s&/home/trufsnd/SNDBUILD/sw/slc7_x86-64/lhapdf/v6.2.3-local2/&${LHAPDF_ROOT}/&g" ${BUILDDIR}/Makefile
sed -i "s&/home/trufsnd/SNDBUILD/sw/slc7_x86-64/lhapdf/v6.2.3-local2/&${LHAPDF_ROOT}/&g" ${BUILDDIR}/*/Makefile
sed -i "s&/home/trufsnd/SNDBUILD/sw/slc7_x86-64/lhapdf/v6.2.3-local2/&${LHAPDF_ROOT}/&g" ${BUILDDIR}/*/*/Makefile
sed -i "s&os.popen('lhapdf-config --libdir').read()&os.environ[\"LHAPDF_ROOT\"]+'/lib'&g" ${BUILDDIR}/pywrap/setup.py
# END HORIBLENESS

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
