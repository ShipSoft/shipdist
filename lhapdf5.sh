package: lhapdf5
tag: v5.9.1-ship2
version: "%(tag_basename)s"
source: https://github.com/ShipSoft/LHAPDF.git
env:
  LHAPATH: "$LHAPDF5_ROOT/share/lhapdf"
  GEANT4_INSTALL: "$GEANT4_ROOT"
requires:
 - "GCC-Toolchain:(?!osx)"
---
#!/bin/bash -ex

rsync -a --exclude '**/.git' "$SOURCEDIR"/ ./

# Point to right python version, if unversioned python exists
command -v python >/dev/null 2>&1 && command -v python2 >/dev/null 2>&1 && PYTHON=$(command -v python2) && export PYTHON

export FFLAGS=--std=legacy

./configure --prefix="$INSTALLROOT"

make ${JOBS+-j $JOBS} all
make install


pushd "$INSTALLROOT"/share/lhapdf
  #PDF sets
  cat > pdfs.txt << EoF
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_nf4.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_nf3.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0127.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0126.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0125.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0124.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0123.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0122.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0121.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0120.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0119.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0118.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0117.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0116.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0115.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0114.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0113.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo_as_0112.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wnlo.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wf4.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10wf3.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10was.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10w.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0130.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0129.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0128.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0127.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0126.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0125.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0124.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0123.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0122.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0121.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0120.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0119.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0118.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0117.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0116.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0115.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0114.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0113.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0112.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0111.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo_as_0110.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nnlo.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_nf4.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_nf3.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0127.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0126.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0125.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0124.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0123.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0122.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0121.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0120.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0119.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0118.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0117.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0116.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0115.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0114.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0113.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0112.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10f4.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10f3.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10as.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_nf4.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_nf3.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0127.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0126.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0125.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0124.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0123.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0122.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0121.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0120.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0119.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0118.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0117.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0116.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0115.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0114.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0113.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/CT10nlo_as_0112.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/cteq4m.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/cteq66alphas.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/cteq66a3.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/cteq66a2.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/cteq66a1.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/cteq66a0.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/cteq66a0.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/cteq6ll.LHpdf
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/cteq6l.LHpdf
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/cteq6lg.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/cteq6ll.LHpdf
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/EPS09LOR_208.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/EPS09NLOR_208.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo_mcrange_nf3.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo_mcrange.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo_mcrange_fixasmz_nf3.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo_mcrange_fixasmz.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo_mbrange_nf4.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo_mbrange.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo_asmzrange.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo90cl_nf4.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo90cl_nf4as5.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo90cl_nf3.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo90cl.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo90cl_asmz+90cl.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo90cl_asmz-90cl.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo90cl_asmz+90clhalf.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo90cl_asmz-90clhalf.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo68cl_nf4.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo68cl_nf4as5.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo68cl_nf3.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo68cl.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo68cl_asmz+68cl.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo68cl_asmz-68cl.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo68cl_asmz+68clhalf.LHgrid
https://www.hepforge.org/archive/lhapdf/pdfsets/5.9.1/MSTW2008nnlo68cl_asmz-68clhalf.LHgrid
EoF
  # Download pdfs
  xargs -a pdfs.txt -I{} curl -O {} -L
popd

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
module load BASE/1.0 ${GCC_TOOLCHAIN_ROOT:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
setenv LHAPDF5_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv LHAPATH \$::env(LHAPDF5_ROOT)/share/lhapdf
prepend-path PATH $::env(LHAPDF5_ROOT)/bin
prepend-path LD_LIBRARY_PATH $::env(LHAPDF5_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH $::env(LHAPDF5_ROOT)/lib")
EoF
