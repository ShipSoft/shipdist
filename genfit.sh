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

# Patch CMakeLists.txt to pass bare header names to ROOT_GENERATE_DICTIONARY
# instead of absolute paths. Absolute paths get embedded in the dictionary's
# $clingAutoload$ annotations, causing errors at runtime when the source
# directory no longer exists (e.g. on CVMFS). The existing INCLUDE_DIRECTORIES
# call already ensures rootcling can find the bare header names.
sed -i 's|\${CMAKE_CURRENT_SOURCE_DIR}/[^/]*/include/||g' "$SOURCEDIR/CMakeLists.txt"

: ${BUILD_TESTING:=OFF}
cmake $SOURCEDIR                                                                            \
      ${CMAKE_GENERATOR:+-G "$CMAKE_GENERATOR"}                                             \
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
