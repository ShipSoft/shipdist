package: apfel
version: 3.1.1
tag: 3.1.1
source: https://github.com/scarrazza/apfel.git
requires:
  - lhapdf
build_requires:
  - CMake
env:
  LD_LIBRARY_PATH: "$LD_LIBRARY_PATH:$APFEL_ROOT/lib"
prefer_system_check: |
  #!/bin/bash -e
  ls $APFEL_ROOT/bin > /dev/null && \
  ls $APFEL_ROOT/lib > /dev/null && \
  ls $APFEL_ROOT/include > /dev/null && \
  true
---
#!/bin/bash -ex

cmake -S $SOURCEDIR -B .                                        \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                       \
      ${CMAKE_GENERATOR:+-G "$CMAKE_GENERATOR"}                 \
      ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE} \
      -DCMAKE_INSTALL_LIBDIR=lib                                \
      -DAPFEL_DOWNLOAD_PDFS=OFF                                 \
      -DAPFEL_ENABLE_TESTS=OFF                                  \
      -DAPFEL_ENABLE_PYTHON=OFF

cmake --build . -- ${JOBS:+-j$JOBS} install

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
module load BASE/1.0
# Environment
setenv APFEL_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(APFEL_ROOT)/lib
EoF
