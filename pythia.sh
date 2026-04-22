package: pythia
version: "%(tag_basename)s"
tag: pythia8317
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
  command -v pythia8-config > /dev/null && \
  printf "#include \"Pythia8/Pythia.h\"\nint main(){}" | c++ -xc++ - ${PYTHIA_ROOT:+-I$PYTHIA_ROOT/include} -c -o /dev/null
build_requires:
  - alibuild-recipe-tools
---
#!/bin/bash -e
rsync -a $SOURCEDIR/ ./

./configure --prefix=$INSTALLROOT \
            --enable-shared \
            --with-hepmc2=${HEPMC_ROOT} \
            ${BOOST_ROOT:+--with-boost="$BOOST_ROOT"} \
            ${LHAPDF_ROOT:+--with-lhapdf6="$LHAPDF_ROOT"}

make ${JOBS+-j $JOBS}
make install
chmod a+x $INSTALLROOT/bin/pythia8-config

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv PYTHIA_ROOT \$PKG_ROOT
setenv PYTHIA8DATA \$PKG_ROOT/share/Pythia8/xmldoc
setenv PYTHIA8 \$PKG_ROOT
EoF
