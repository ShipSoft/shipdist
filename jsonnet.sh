package: jsonnet
version: "%(tag_basename)s"
tag: v0.20.0
source: https://github.com/google/jsonnet
requires:
  - "GCC-Toolchain:(?!osx)"
  - nlohmann_json
build_requires:
  - CMake
  - alibuild-recipe-tools
---
#!/bin/bash -e

# jsonnet's USE_SYSTEM_JSON does find_package(nlohmann_json) but the source
# includes "json.hpp" (bare), while the system package installs
# "nlohmann/json.hpp".  Point the include path at the nlohmann/ subdirectory
# so the bare include resolves.
cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_CXX_STANDARD="${CMAKE_CXX_STANDARD:-23}" \
  -Dnlohmann_json_DIR="$NLOHMANN_JSON_ROOT/share/cmake/nlohmann_json" \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DBUILD_TESTS=OFF \
  -DUSE_SYSTEM_JSON=ON \
  -DBUILD_SHARED_BINARIES=ON \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS:+$CXXFLAGS }-I$NLOHMANN_JSON_ROOT/include/nlohmann"

cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
