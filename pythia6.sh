# a pythia6 recipe based on the one from FairROOT
package: pythia6
version: "%(tag_basename)s"
tag: v6.4.28-snd
source: https://github.com/SND-LHC/pythia6
requires:
  - GCC-Toolchain
prefer_system_check: |
  ls $PYTHIA6_ROOT/lib/libpythia6.so > /dev/null && \
  ls $PYTHIA6_ROOT/lib/libPythia6.so > /dev/null
build_requires:
  - CMake
  - alibuild-recipe-tools
---
#!/bin/sh

cmake ${SOURCEDIR}                           \
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -DCMAKE_INSTALL_PREFIX=${INSTALLROOT}  \
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -DCMAKE_INSTALL_LIBDIR=lib
make ${JOBS+-j$JOBS}
make install

cp $INSTALLROOT/lib/libpythia6.so $INSTALLROOT/lib/libPythia6.so

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv PYTHIA6 \$PKG_ROOT
prepend-path AGILE_GEN_PATH \$PKG_ROOT
EoF
