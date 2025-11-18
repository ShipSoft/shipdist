package: fmt
version: "%(tag_basename)s"
tag: 11.2.0
source: https://github.com/fmtlib/fmt
requires:
  - "GCC-Toolchain:(?!osx)"
build_requires:
  - CMake
prepend_path:
  ROOT_INCLUDE_PATH: "$FMT_ROOT/include"
prefer_system_check: |
    if [ -z "$FMT_VERSION" ]; then
        FMT_VERSION=$(pkg-config --modversion fmt 2>/dev/null)
    fi
    verge() { [[  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]]; }
    verge $REQUESTED_VERSION $FMT_VERSION
---
#!/bin/bash -e
cmake $SOURCEDIR -DCMAKE_INSTALL_PREFIX=$INSTALLROOT -DFMT_TEST=OFF

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
module load BASE/1.0 ${GCC_TOOLCHAIN_REVISION:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
set FMT_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path ROOT_INCLUDE_PATH \$FMT_ROOT/include
EoF
