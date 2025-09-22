package: HepMC
version: "%(tag_basename)s%(defaults_upper)s"
source: https://github.com/alisw/hepmc
tag: alice/v2.06.09
build_requires:
  - CMake
  - GCC-Toolchain:(?!osx.*)
prefer_system_check: |
  #!/bin/bash -e
  ls $HEPMC_ROOT/lib > /dev/null && \
  ls $HEPMC_ROOT/lib/libHepMC.so > /dev/null && \
  ls $HEPMC_ROOT/lib/libHepMC.so.4 > /dev/null && \
  ls $HEPMC_ROOT/lib/libHepMC.a > /dev/null && \
  ls $HEPMC_ROOT/lib/libHepMCfio.so > /dev/null && \
  ls $HEPMC_ROOT/lib/libHepMCfio.so.4 > /dev/null && \
  ls $HEPMC_ROOT/lib/libHepMCfio.a > /dev/null && \
  ls $HEPMC_ROOT/include > /dev/null && \
  ls $HEPMC_ROOT/include/HepMC > /dev/null && \
  ls $HEPMC_ROOT/include/HepMC/HepMCDefs.h > /dev/null && \
  grep "2.06" $HEPMC_ROOT/include/HepMC/HepMCDefs.h > /dev/null
---
#!/bin/bash -e

cmake  $SOURCEDIR                           \
       -Dmomentum=GEV                       \
       -Dlength=MM                          \
       -Dbuild_docs:BOOL=OFF                \
       -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

make ${JOBS+-j $JOBS}
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
module load BASE/1.0 ${GCC_TOOLCHAIN_ROOT:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
setenv HEPMC_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(HEPMC_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(HEPMC_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(HEPMC_ROOT)/lib")
EoF
