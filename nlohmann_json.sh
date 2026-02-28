package: nlohmann_json
version: "%(tag_basename)s"
source: https://github.com/nlohmann/json.git
tag: v3.11.3
prefer_system: .*
prefer_system_check: |
  #!/bin/bash -e
  printf '#include <nlohmann/json.hpp>\nint main(){}\n' | \
    c++ -std=c++20 -xc++ - \
    ${NLOHMANN_JSON_ROOT:+-I"$NLOHMANN_JSON_ROOT/include"} \
    -o /dev/null
build_requires:
  - "GCC-Toolchain:(?!osx)"
  - CMake
  - alibuild-recipe-tools
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DJSON_BuildTests=OFF
cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
# Our environment
set NLOHMANN_JSON_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path ROOT_INCLUDE_PATH \$NLOHMANN_JSON_ROOT/include
EoF
