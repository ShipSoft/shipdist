package: ROOTEGPythia6
version: "%(tag_basename)s"
tag: feb7c7eb8d368aee20bf1cb01f1bbfb9cfaeb6b5
source: https://github.com/luketpickering/ROOTEGPythia6
requires:
  - ROOT
  - pythia6
  - GCC-Toolchain
build_requires:
  - CMake
env:
  ROOTEGPYTHIA6: "$ROOTEGPYTHIA6_ROOT"
prepend_path:
  LD_LIBRARY_PATH: "$ROOTEGPYTHIA6_ROOT/lib"
  ROOT_INCLUDE_PATH: "$ROOTEGPYTHIA6_ROOT/include"
  CMAKE_MODULE_PATH: "$ROOTEGPYTHIA6_ROOT/lib/cmake/ROOTEGPythia6/Modules"
prefer_system_check: |
    if [ ! -z "$ROOTEGPYTHIA6_VERSION" ]; then
        exit 0
    fi
    exit 1
---
#!/bin/bash -e

# Patch CMakeLists.txt to pass bare header names to ROOT_GENERATE_DICTIONARY
# instead of absolute paths. Absolute paths get embedded in the dictionary's
# $clingAutoload$ annotations, causing errors at runtime when the source
# directory no longer exists (e.g. on CVMFS).
# shellcheck disable=SC2016
sed -i \
  -e 's|${CMAKE_CURRENT_LIST_DIR}/inc/\(.*\.h\)|\1|g' \
  -e '/^ROOT_GENERATE_DICTIONARY/i include_directories(${CMAKE_CURRENT_LIST_DIR}/inc)' \
  "$SOURCEDIR/CMakeLists.txt"

# Patch the exported package config so downstream consumers (e.g. FairShip,
# which has FairRoot's FindPythia6 on CMAKE_MODULE_PATH) get the
# Pythia6::Pythia6 IMPORTED target that ROOTEGPythia6Targets.cmake links
# against. FairRoot's FindPythia6 creates a non-namespaced "Pythia6" target;
# upstream ROOTEGPythia6 expects "Pythia6::Pythia6". Define the namespaced
# target directly so we don't depend on whichever FindPythia6 module the
# consumer picks up first.
sed -i 's|find_package(Pythia6 REQUIRED)|if(NOT TARGET Pythia6::Pythia6)\n  if(NOT DEFINED ENV{PYTHIA6_ROOT} OR NOT EXISTS "$ENV{PYTHIA6_ROOT}/lib/libPythia6.so")\n    message(FATAL_ERROR "ROOTEGPythia6 requires PYTHIA6_ROOT to point to a directory containing lib/libPythia6.so")\n  endif()\n  add_library(Pythia6::Pythia6 SHARED IMPORTED)\n  set_target_properties(Pythia6::Pythia6 PROPERTIES IMPORTED_LOCATION "$ENV{PYTHIA6_ROOT}/lib/libPythia6.so")\nendif()|' \
  "$SOURCEDIR/cmake/Templates/ROOTEGPythia6Config.cmake.in"

cmake "$SOURCEDIR" \
      -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -DROOTEGPythia6_Pythia6_BUILTIN=OFF \
      -DPYTHIA6_LIB_DIR="$PYTHIA6_ROOT/lib" \
      -DCMAKE_POLICY_DEFAULT_CMP0144=NEW \
      -DCMAKE_INSTALL_LIBDIR=lib

cmake --build . ${JOBS:+-j$JOBS}
cmake --install .

# Fix rootmap: dictionary is named TPythia6 but library is EGPythia6
# (upstream bug — contribute fix, keep this patch until merged)
sed -i 's/libTPythia6\.so/libEGPythia6.so/' "$INSTALLROOT/lib/libTPythia6.rootmap"
mv "$INSTALLROOT/lib/libTPythia6.rootmap" "$INSTALLROOT/lib/libEGPythia6.rootmap"
mv "$INSTALLROOT/lib/libTPythia6_rdict.pcm" "$INSTALLROOT/lib/libEGPythia6_rdict.pcm"

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EOF
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
EOF
