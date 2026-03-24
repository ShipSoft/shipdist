package: GENIE
version: v3.6.2
tag: R-3_06_02
source: https://github.com/GENIE-MC/Generator.git
requires:
  - GCC-Toolchain
  - ROOT
  - lhapdf
  - apfel
  - pythia
  - log4cpp
  - GSL
  - libxml2
env:
  GENIE: "$GENIE_ROOT/genie"
  PATH: "$PATH:$GENIE_ROOT/genie/bin"
  LD_LIBRARY_PATH: "$LD_LIBRARY_PATH:$GENIE_ROOT/genie/lib"
  ROOT_INCLUDE_PATH: "$ROOT_INCLUDE_PATH:$GENIE_ROOT/genie/inc:$GENIE_ROOT/genie/src"
prefer_system_check: |
  #!/bin/bash -e
  ls $GENIE_ROOT/genie > /dev/null && \
  ls $GENIE_ROOT/genie/bin > /dev/null && \
  ls $GENIE_ROOT/genie/config > /dev/null && \
  ls $GENIE_ROOT/genie/data > /dev/null && \
  ls $GENIE_ROOT/genie/inc > /dev/null && \
  ls $GENIE_ROOT/genie/lib > /dev/null && \
  ls $GENIE_ROOT/genie/src > /dev/null && \
  true
build_requires:
  - alibuild-recipe-tools
---
#!/bin/bash -ex
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
		    --disable-pythia6 \
		    --enable-pythia8 \
		    --enable-mathmore \
      		    --with-pythia8-lib=$PYTHIA_ROOT/lib/ \
      		    --with-pythia8-inc=$PYTHIA_ROOT/include/ \
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
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv GENIE \$PKG_ROOT/genie
prepend-path LD_LIBRARY_PATH \$PKG_ROOT/genie/lib
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/genie/inc
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/genie/src
append-path PATH \$PKG_ROOT/genie/bin
EoF
