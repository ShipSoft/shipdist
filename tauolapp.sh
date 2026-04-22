package: Tauolapp
version: "%(tag_basename)s"
tag: v1.1.8
source: https://gitlab.cern.ch/tauolapp/tauolapp
requires:
  - HepMC3
  - ROOT
  - pythia
prefer_system_check: |
  ls "$TAUOLAPP_ROOT"/lib/libTauolaHepMC3.so > /dev/null && \
  ls "$TAUOLAPP_ROOT"/lib/libTauolaCxxInterface.so > /dev/null && \
  ls "$TAUOLAPP_ROOT"/lib/libTauolaFortran.so > /dev/null && \
  ls "$TAUOLAPP_ROOT"/include/Tauola > /dev/null
---
#!/bin/sh

rsync -a $SOURCEDIR/* .

F77=gfortran ./configure --with-hepmc3=$HEPMC3_ROOT --without-hepmc \
            --with-pythia8=$PYTHIA_ROOT --prefix=$INSTALLROOT

mkdir -p lib
make
make install DESTDIR= PREFIX=$INSTALLROOT LIBDIR=$INSTALLROOT/lib

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
module load BASE/1.0 ${ROOT_REVISION:+ROOT/$ROOT_VERSION-$ROOT_REVISION} ${PYTHIA_REVISION:+pythia/$PYTHIA_VERSION-$PYTHIA_REVISION} ${HEPMC3_REVISION:+HepMC3/$HEPMC3_VERSION-$HEPMC3_REVISION}
# Our environment
setenv TAUOLA_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(TAUOLA_ROOT)/lib
EoF

cat $MODULEFILE
