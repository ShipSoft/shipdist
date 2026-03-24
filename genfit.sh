package: GenFit
version: 02-03-00
source: https://github.com/GenFit/GenFit
requires:
  - ROOT
  - googletest # should be build dep?
  - boost
build_requires:
  - CMake
  - GCC-Toolchain
  - alibuild-recipe-tools
env:
  GENFIT: "$GENFIT_ROOT"
prepend_path:
  ROOT_INCLUDE_PATH: "$GENFIT_ROOT/include"
  LD_LIBRARY_PATH: "$GENFIT_ROOT/lib"
prefer_system_check: |
    ls $GENFIT_ROOT/include && \
    ls $GENFIT_ROOT/lib
---
#!/bin/bash -e
: ${BUILD_TESTING:=OFF}
cmake $SOURCEDIR                                                                            \
      ${CMAKE_GENERATOR:+-G "$CMAKE_GENERATOR"}                                             \
      ${MACOSX_RPATH:+-DMACOSX_RPATH=${MACOSX_RPATH}}                                       \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS"                                                         \
      ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE}                             \
      -DGTEST_ROOT=$GOOGLETEST_ROOT \
      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                                               \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                                                    \
      -DCMAKE_INSTALL_LIBDIR=lib                                                            \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      -DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -DROOT_DIR="${ROOT_ROOT}" \
      -DBUILD_TESTING=${BUILD_TESTING}


cmake --build . -- -j$JOBS install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
setenv GENFIT \$PKG_ROOT
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
EoF
