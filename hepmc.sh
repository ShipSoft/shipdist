package: HepMC
version: "%(tag_basename)s%(defaults_upper)s"
source: https://github.com/alisw/hepmc
tag: alice/v2.06.09
build_requires:
  - CMake
  - GCC-Toolchain
  - alibuild-recipe-tools
prefer_system_check: |
  #!/bin/bash -e
  printf "#include \"HepMC/HepMCDefs.h\"\nint main(){}" | c++ -xc++ - -c -o /dev/null
---
#!/bin/bash -e

cmake  $SOURCEDIR                           \
       -Dmomentum=GEV                       \
       -Dlength=MM                          \
       -Dbuild_docs:BOOL=OFF                \
       -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
       -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

make ${JOBS+-j $JOBS}
make install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
