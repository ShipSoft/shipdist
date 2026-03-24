package: fmt
version: "%(tag_basename)s"
tag: 11.2.0
source: https://github.com/fmtlib/fmt
requires:
  - GCC-Toolchain
build_requires:
  - CMake
  - alibuild-recipe-tools
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
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
EoF
