package: lhapdf
version: "%(tag_basename)s%(defaults_upper)s"
tag: lhapdf-6.5.5
source:  https://gitlab.com/hepcedar/lhapdf
requires:
 - "Python:slc.*"
 - "Python-system:(?!slc.*)"
 - GCC-Toolchain
build_requires:
 - autotools
 - alibuild-recipe-tools
env:
  LHAPATH: "$LHAPDF_ROOT/share/LHAPDF"
prefer_system_check: |
  #!/bin/bash -e
  which lhapdf-config > /dev/null && \
  printf "#include \"LHAPDF/LHAPDF.h\"\nint main(){}" | c++ -xc++ - -c -o /dev/null
---
#!/bin/bash -ex
rsync -a --exclude '**/.git' "$SOURCEDIR"/ ./

autoreconf -ivf
./configure --prefix="$INSTALLROOT" --disable-python

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
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv LHAPATH \$PKG_ROOT/share/LHAPDF
EoF
