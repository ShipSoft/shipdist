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
---
#!/bin/bash -ex
export GENIE="$BUILDDIR"

# When using system/LCG packages, the *_ROOT variables may not be set.
# Detect lib/include paths from config tools, falling back to $PKG_ROOT/{lib,include}.
PYTHIA8_LIBDIR=${PYTHIA_ROOT:+$PYTHIA_ROOT/lib}
PYTHIA8_INCDIR=${PYTHIA_ROOT:+$PYTHIA_ROOT/include}
: ${PYTHIA8_LIBDIR:=$(pythia8-config --libdir 2>/dev/null)}
: ${PYTHIA8_INCDIR:=$(pythia8-config --includedir 2>/dev/null)}

LHAPDF_LIBDIR=${LHAPDF_ROOT:+$LHAPDF_ROOT/lib}
LHAPDF_INCDIR=${LHAPDF_ROOT:+$LHAPDF_ROOT/include}
: ${LHAPDF_LIBDIR:=$(lhapdf-config --libdir 2>/dev/null)}
: ${LHAPDF_INCDIR:=$(lhapdf-config --incdir 2>/dev/null)}

APFEL_LIBDIR=${APFEL_ROOT:+$APFEL_ROOT/lib}
APFEL_INCDIR=${APFEL_ROOT:+$APFEL_ROOT/include}
: ${APFEL_LIBDIR:=$(apfel-config --libdir 2>/dev/null)}
: ${APFEL_INCDIR:=$(apfel-config --incdir 2>/dev/null)}

LIBXML2_LIBDIR=${LIBXML2_ROOT:+$LIBXML2_ROOT/lib}
LIBXML2_INCDIR=${LIBXML2_ROOT:+$LIBXML2_ROOT/include/libxml2}
: ${LIBXML2_LIBDIR:=$(pkg-config --variable=libdir libxml-2.0 2>/dev/null)}
if [[ -z "$LIBXML2_INCDIR" ]]; then
  _xml2_incdir=$(pkg-config --variable=includedir libxml-2.0 2>/dev/null)
  [[ -n "$_xml2_incdir" ]] && LIBXML2_INCDIR=$_xml2_incdir/libxml2
  unset _xml2_incdir
fi

LOG4CPP_LIBDIR=${LOG4CPP_ROOT:+$LOG4CPP_ROOT/lib}
LOG4CPP_INCDIR=${LOG4CPP_ROOT:+$LOG4CPP_ROOT/include}
# log4cpp has no config tool; search LD_LIBRARY_PATH
if [[ -z "$LOG4CPP_LIBDIR" ]]; then
  for _dir in $(echo "$LD_LIBRARY_PATH" | tr ':' '\n'); do
    if [[ -f "$_dir/liblog4cpp.so" ]]; then
      LOG4CPP_LIBDIR=$_dir
      LOG4CPP_INCDIR=$(dirname "$_dir")/include
      break
    fi
  done
  unset _dir
fi

rsync -a $SOURCEDIR/* $BUILDDIR
ls -alh $BUILDDIR
sed -i 's/libAPFEL.la/libAPFEL.so/' $BUILDDIR/configure
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
      		    --with-pythia8-lib=$PYTHIA8_LIBDIR/ \
      		    --with-pythia8-inc=$PYTHIA8_INCDIR/ \
		    --with-lhapdf6-lib=$LHAPDF_LIBDIR/ \
		    --with-lhapdf6-inc=$LHAPDF_INCDIR/ \
		    --with-libxml2-lib=$LIBXML2_LIBDIR/ \
		    --with-libxml2-inc=$LIBXML2_INCDIR \
		    --with-log4cpp-inc=$LOG4CPP_INCDIR/ \
		    --with-log4cpp-lib=$LOG4CPP_LIBDIR/ \
		    --with-apfel-inc=$APFEL_INCDIR/ \
		    --with-apfel-lib=$APFEL_LIBDIR/


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
module load BASE/1.0 ${ROOT_REVISION:+ROOT/$ROOT_VERSION-$ROOT_REVISION} ${PYTHIA_REVISION:+pythia/$PYTHIA_VERSION-$PYTHIA_REVISION} ${LHAPDF_REVISION:+lhapdf/$LHAPDF_VERSION-$LHAPDF_REVISION} ${LOG4CPP_REVISION:+log4cpp/$LOG4CPP_VERSION-$LOG4CPP_REVISION} ${LIBXML2_REVISION:+libxml2/$LIBXML2_VERSION-$LIBXML2_REVISION} ${GSL_VERSION:+GSL/$GSL_VERSION-$GSL_REVISION} ${APFEL_REVISION:+apfel/$APFEL_VERSION-$APFEL_REVISION}
# Our environment
setenv GENIE_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv GENIE \$::env(GENIE_ROOT)/genie
prepend-path LD_LIBRARY_PATH \$::env(GENIE_ROOT)/genie/lib
prepend-path ROOT_INCLUDE_PATH \$::env(GENIE_ROOT)/genie/inc
prepend-path ROOT_INCLUDE_PATH \$::env(GENIE_ROOT)/genie/src
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(GENIE_ROOT)/lib")
append-path PATH \$::env(GENIE_ROOT)/genie/bin
EoF
