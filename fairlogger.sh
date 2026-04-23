package: FairLogger
version: "%(tag_basename)s"
tag: v2.3.1
source: https://github.com/FairRootGroup/FairLogger
requires:
  - fmt
build_requires:
  - CMake
  - GCC-Toolchain
  - alibuild-recipe-tools
prepend_path:
  ROOT_INCLUDE_PATH: "$FAIRLOGGER_ROOT/include"
prefer_system_check: |
  #!/bin/bash -e
  REQUESTED_VERSION=${REQUESTED_VERSION#v}
  verge() { [[  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]]; }
  verge $REQUESTED_VERSION $FAIRLOGGER_VERSION
---
#!/bin/bash

mkdir -p $INSTALLROOT

cmake $SOURCEDIR                                                 \
      ${CXX_COMPILER:+-DCMAKE_CXX_COMPILER=$CXX_COMPILER}        \
      ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE}  \
      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                    \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                        \
      -DDISABLE_COLOR=ON                                         \
      -DUSE_EXTERNAL_FMT=ON                                      \
      -DCMAKE_INSTALL_LIBDIR=lib

cmake --build . ${JOBS:+-- -j$JOBS}
ctest ${JOBS:+-j$JOBS}
cmake --build . --target install ${JOBS:+-- -j$JOBS}

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<\EoF
prepend-path ROOT_INCLUDE_PATH $PKG_ROOT/include
EoF
