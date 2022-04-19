package: GENIE
version: v3.2.0
tag: R-3_02_00
source: https://github.com/GENIE-MC/Generator.git
requires:
  - GCC-Toolchain
  - ROOT
  - lhapdf
  - apfel
  - pythia6
  - log4cpp
  - GSL
  - libxml2
env:
  GENIE: "$GENIE_ROOT/genie"
  PATH: "$PATH:$GENIE_ROOT/genie/bin"
  LD_LIBRARY_PATH: "$LD_LIBRARY_PATH:$GENIE_ROOT/genie/lib"
  ROOT_INCLUDE_PATH: "$ROOT_INCLUDE_PATH:$GENIE_ROOT/genie/inc:$GENIE_ROOT/genie/src"
---  
#/bin/bash -ex
export GENIE="$BUILDDIR"

rsync -a $SOURCEDIR/* $BUILDDIR
ls -alh $BUILDDIR
$BUILDDIR/configure --prefix=$INSTALLROOT \
		    --enable-lhapdf6 \
                    --enable-apfel \
                    --enable-fnal \
		    --enable-validation-tools \
		    --enable-test \
		    --enable-boosted-dark-matter \
		    --enable-neutral-heavy-lepton \
		    --enable-dark-neutrino \
		    --enable-rwght \
		    --enable-pyhia6 \
		    --enable-mathmore \
      		    --with-pythia6-lib=$PYTHIA6_ROOT/lib/ \
		    --with-lhapdf-lib=$LHAPDF_ROOT/lib/ \
		    --with-lhapdf-inc=$LHAPDF_ROOT/include/ \
		    --with-libxml2-lib=$LIBXML2_ROOT/lib/ \
		    --with-libxml2-inc=$LIBXML2_ROOT/include/libxml2 \
		    --with-log4cpp-inc=$LOG4CPP_ROOT/include/ \
		    --with-log4cpp-lib=$LOG4CPP_ROOT/lib/ \
		    --with-apfel-inc=$APFEL_ROOT/include/ \
		    --with-apfel-lib=$APFEL_ROOT/lib/ 


make CXXFLAGS="-Wall $CXXFLAGS" CFLAGS="-Wall $CFLAGS"
make install

# make command does not work, do it by hand
mkdir -p $INSTALLROOT/genie/lib
rsync -a lib/* $INSTALLROOT/genie/lib
rsync -a src/*/*/*.pcm  $INSTALLROOT/genie/lib
mkdir -p $INSTALLROOT/genie/bin
rsync -a bin/* $INSTALLROOT/genie/bin
mkdir -p $INSTALLROOT/genie/data
rsync -a data/* $INSTALLROOT/genie/data
mkdir -p $INSTALLROOT/genie/config
rsync -a config/* $INSTALLROOT/genie/config
mkdir -p $INSTALLROOT/genie/src
rsync -a src/* $INSTALLROOT/genie/src
mkdir -p $INSTALLROOT/genie/inc
rsync -a src/*/*/*.h $INSTALLROOT/genie/inc

#cp $INSTALLROOT/genie/data/evgen/pdfs/GRV98lo_patched.LHgrid $LHAPDF5_ROOT/share/lhapdf

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
module load BASE/1.0 ROOT/$ROOT_VERSION-$ROOT_REVISION pythia6/$PYTHIA6_VERSION-$PYTHIA6_REVISION lhapdf/$LHAPDF_VERSION-$LHAPDF_REVISION log4cpp/$LOG4CPP_VERSION-$LOG4CPP_REVISION ${LIBXML2:+libxml2/$LIBXML2_VERSION-$LIBXML2_REVISION} ${GSL_VERSION:+GSL/$GSL_VERSION-$GSL_REVISION} apfel/$APFEL_VERSION-$APFEL_REVISION
# Our environment
setenv GENIE_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv GENIE \$::env(GENIE_ROOT)/genie
prepend-path LD_LIBRARY_PATH \$::env(GENIE_ROOT)/genie/lib
prepend-path ROOT_INCLUDE_PATH \$::env(GENIE_ROOT)/genie/inc
prepend-path ROOT_INCLUDE_PATH \$::env(GENIE_ROOT)/genie/src
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(GENIE_ROOT)/lib")
append-path PATH \$::env(GENIE_ROOT)/genie/bin 
EoF
