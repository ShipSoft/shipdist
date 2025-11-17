package: pythia
version: "%(tag_basename)s"
tag: pythia8316
source: https://gitlab.com/Pythia8/releases
requires:
  - lhapdf
  - HepMC
  - boost
env:
  PYTHIA8DATA: "$PYTHIA_ROOT/share/Pythia8/xmldoc"
  PYTHIA8: "$PYTHIA_ROOT"
prefer_system_check: |
  #!/bin/bash -e
  ls $PYTHIA_ROOT/bin > /dev/null && \
  ls $PYTHIA_ROOT/bin/pythia8-config > /dev/null && \
  ls $PYTHIA_ROOT/include/ > /dev/null && \
  ls $PYTHIA_ROOT/include/Pythia8 > /dev/null && \
  ls $PYTHIA_ROOT/include/Pythia8Plugins > /dev/null && \
  ls $PYTHIA_ROOT/lib/libpythia8.a > /dev/null && \
  ls $PYTHIA_ROOT/lib/libpythia8lhapdf6.so > /dev/null && \
  ls $PYTHIA_ROOT/lib/libpythia8.so > /dev/null && \
  true
---
#!/bin/bash -e
rsync -a $SOURCEDIR/ ./
case $ARCHITECTURE in
  osx*)
    # If we preferred system tools, we need to make sure we can pick them up.
    [[ ! $BOOST_ROOT ]] && BOOST_ROOT=`brew --prefix boost`
  ;;
esac

./configure --prefix=$INSTALLROOT \
            --enable-shared \
            --with-hepmc2=${HEPMC_ROOT} \
            ${BOOST_ROOT:+--with-boost="$BOOST_ROOT"} \
            ${LHAPDF_ROOT:+--with-lhapdf6="$LHAPDF_ROOT"}

make ${JOBS+-j $JOBS}
make install
chmod a+x $INSTALLROOT/bin/pythia8-config

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
module load BASE/1.0 ${LHAPDF_VERSION:+lhapdf/$LHAPDF_VERSION-$LHAPDF_REVISION} ${BOOST_VERSION:+boost/$BOOST_VERSION-$BOOST_REVISION} HepMC/$HEPMC_VERSION-$HEPMC_REVISION
# Our environment
setenv PYTHIA_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv PYTHIA8DATA \$::env(PYTHIA_ROOT)/share/Pythia8/xmldoc
setenv PYTHIA8 \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(PYTHIA_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(PYTHIA_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(PYTHIA_ROOT)/lib")
EoF
