package: lhapdf
version: "%(tag_basename)s%(defaults_upper)s"
tag: lhapdf-6.5.3-snd
source:  https://github.com/SND-LHC/lhapdf
requires:
 - Python-modules
 - "Python:slc.*"
 - "Python-system:(?!slc.*)"
 - "GCC-Toolchain:(?!osx)"
build_requires:
 - autotools
env:
  LHAPATH: "$LHAPDF_ROOT/share/LHAPDF"
---
#!/bin/bash -ex
case $ARCHITECTURE in
  osx*)
    # If we preferred system tools, we need to make sure we can pick them up.
    [[ ! $AUTOTOOLS_ROOT ]] && PATH=$PATH:$(brew --prefix gettext)/bin
  ;;
  *)
    EXTRA_LD_FLAGS="-Wl,--no-as-needed"
  ;;
esac

rsync -a --exclude '**/.git' "$SOURCEDIR"/ ./

autoreconf -ivf
./configure --prefix="$INSTALLROOT"

make ${JOBS+-j $JOBS} all
make install

PDFSETS="cteq6l1 MMHT2014lo68cl MMHT2014nlo68cl HERAPDF15NLO_EIG NNPDF31_nnlo_as_0118_luxqed NNPDF31_nnlo_as_0118"
#$INSTALLROOT/bin/lhapdf install $PDFSETS
# Check if PDF sets were really installed
for P in $PDFSETS; do
  curl -L https://lhapdfsets.web.cern.ch/lhapdfsets/current/"$P".tar.gz | tar xz -C "$INSTALLROOT"/share/LHAPDF
  ls "$INSTALLROOT"/share/LHAPDF/"$P"
done

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
# Our environment
setenv LHAPDF_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv LHAPATH \$::env(LHAPDF_ROOT)/share/LHAPDF
prepend-path PATH $::env(LHAPDF_ROOT)/bin
prepend-path LD_LIBRARY_PATH $::env(LHAPDF_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH $::env(LHAPDF_ROOT)/lib")
EoF
