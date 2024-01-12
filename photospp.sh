package: PHOTOSPP
version: "%(tag_basename)s"
tag: "v3.64"
source: https://gitlab.cern.ch/photospp/photospp
requires:
  - HepMC
  - ROOT
  - pythia
  - Tauolapp
build_requires:
  - "autotools:(slc6|slc7)"
  - alibuild-recipe-tools
---
#!/bin/bash -e
rsync -a --delete --exclude '**/.git' $SOURCEDIR/ ./

autoreconf -ifv
F77=gfortran ./configure --prefix $INSTALLROOT \
	--with-hepmc="$HEPMC_ROOT" \
	--with-pythia8=$PYTHIA_ROOT \
	--with-tauola=$TAUOLAPP_ROOT
make -j$JOBS
make install

#ModuleFile
mkdir -p $INSTALLROOT/etc/modulefiles
alibuild-generate-module > $INSTALLROOT/etc/modulefiles/$PKGNAME

cat << EOF >> $INSTALLROOT/etc/modulefiles/$PKGNAME
set PHOTOSPP_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv PHOTOSPP_ROOT \$PHOTOSPP_ROOT
setenv PHOTOSPP_INSTALL_PATH \$PHOTOSPP_ROOT/lib/PHOTOS
prepend-path PATH \$PHOTOSPP_ROOT/bin
prepend-path LD_LIBRARY_PATH \$PHOTOSPP_ROOT/lib
EOF
