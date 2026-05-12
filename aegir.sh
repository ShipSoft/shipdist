package: aegir
version: "%(tag_basename)s"
tag: main
source: https://github.com/ShipSoft/aegir.git
requires:
  - data-model
  - PHLEX
  - ROOT
  - boost
  - TBB
  - spdlog
  - GEANT4
  - pythia
  - Random123
  - geometry_service
build_requires:
  - CMake
  - GCC-Toolchain
  - alibuild-recipe-tools
env:
  AEGIR_ROOT: "$AEGIR_ROOT"
prepend_path:
  ROOT_INCLUDE_PATH: "$AEGIR_ROOT/include"
  LD_LIBRARY_PATH: "$AEGIR_ROOT/lib"
  PHLEX_PLUGIN_PATH: "$AEGIR_ROOT/lib"
---
#!/bin/bash -e

# aegir consumes PHLEX (built at C++23); align to C++23 regardless of defaults.
# -Wno-error=cpp tolerates ROOT's C++-standard-mismatch #warning when ROOT is
# built at a different standard (e.g. C++20 under defaults-release).
export CXXFLAGS="${CXXFLAGS//-std=c++*/-std=c++23} -Wno-error=cpp"

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_PREFIX_PATH="$DATA_MODEL_ROOT;$RANDOM123_ROOT;$GEOMETRY_SERVICE_ROOT" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_POLICY_DEFAULT_CMP0144=NEW

cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
# Aegir environment
set AEGIR_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv AEGIR_ROOT \$AEGIR_ROOT
prepend-path PHLEX_PLUGIN_PATH \$AEGIR_ROOT/lib
prepend-path ROOT_INCLUDE_PATH \$AEGIR_ROOT/include
EoF
