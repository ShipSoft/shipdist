package: npdb-client
version: "0.1.1"
tag: master
source: https://gitlab.cern.ch/ship/computing/npdb
build_requires:
  - "GCC-Toolchain:(?!osx)"
  - CMake
  - rust
  - alibuild-recipe-tools
---
#!/bin/bash -e

cmake "$SOURCEDIR/npdb-client" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"

make ${JOBS+-j $JOBS}
make install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EOF
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
EOF
