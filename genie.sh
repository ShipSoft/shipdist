package: GENIE
version: "%(tag_basename)s"
tag: fairshipdev
source: https://github.com/PMunkes/GENIE
requires:
  - GCC-Toolchain
  - ROOT
  - lhapdf5
  - pythia6
  - log4cpp
  - GSL
env:
  GENIE: "$GENIE_ROOT"
---  
#/bin/bash -ex
export GENIE="$BUILDDIR"

cp --reflink=auto -aR $SOURCEDIR/* .
$BUILDDIR/configure --prefix=$INSTALLROOT \
		    --enable-lhapdf \
		    --enable-validation-tools \
		    --enable-test \
		    --enable-numi\
		    --enable-atmo \
		    --enable-nucleon-decay \
		    --enable-rwght \
		    --enable-pyhia6 \
		    --enable-mathmore \
      		    --with-pythia6-lib=$PYTHIA6_ROOT/lib/ \
		    --with-lhapdf-lib=$LHAPDF5_ROOT/lib/ \
		    --with-lhapdf-inc=$LHAPDF5_ROOT/include/ \
		    --with-log4cpp-inc=$LOG4CPP_ROOT/include/ \
		    --with-log4cpp-lib=$LOG4CPP_ROOT/lib/\
		    CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS"

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
module load BASE/1.0 ROOT/$ROOT_VERSION-$ROOT_REVISION pythia6/$PYTHIA6_VERSION-$PYTHIA6_REVISION lhapdf5/$LHAPDF5_VERSION-$LHAPDF5_REVISION log4cpp/$LOG4CPP_VERSION-$LOG4CPP_REVISION GSL/$GSL_VERSION-$GSL_REVISION
# Our environment
setenv GENIE_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv GENIE \$::env(GENIE_ROOT)
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(TAUOLA_ROOT)/lib")
EoF
