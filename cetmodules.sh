package: cetmodules
version: "%(tag_basename)s"
tag: 4.01.01
source: https://github.com/FNALssi/cetmodules
build_requires:
  - CMake
  - GCC-Toolchain
  - alibuild-recipe-tools
---
#!/bin/bash -e

cmake -S "$SOURCEDIR" -B .                                        \
      -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"                       \
      ${CMAKE_GENERATOR:+-G "$CMAKE_GENERATOR"}                   \
      ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE}

cmake --build . --target install ${JOBS:+-- -j$JOBS}

# Patch config so find_package(cetmodules) also includes the modules
# that cetmodules' own CMakeLists.txt loads when used via FetchContent.
# All use include_guard() so double-inclusion is safe.
cat >> "$INSTALLROOT/share/cetmodules/cmake/cetmodulesConfig.cmake" <<'EOF'
include(CetProvideDependency)
include(CetCMakeEnv)
include(CetCMakeUtils)
include(CetCMakeConfig)
include(CetMake)
EOF

mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --cmake > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
