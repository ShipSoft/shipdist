package: hdf5
version: "1.14.6"
tag: hdf5_1.14.6
source: https://github.com/HDFGroup/hdf5.git
requires:
  - GCC-Toolchain
build_requires:
  - CMake
  - alibuild-recipe-tools
prefer_system: .*
prefer_system_check: |
  cat << \EOF | cc -xc -c -o /dev/null $(pkg-config --cflags hdf5 2>/dev/null) -
  #include <hdf5.h>
  EOF
env:
  HDF5_DIR: "$HDF5_ROOT"
---
#!/bin/bash -e
cmake "$SOURCEDIR" \
  -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DBUILD_TESTING=OFF \
  ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD} \
  -DHDF5_BUILD_CPP_LIB=ON

cmake --build . -- ${JOBS:+-j$JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
