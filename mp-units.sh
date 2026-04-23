package: mp-units
version: "%(tag_basename)s"
tag: v2.5.0
source: https://github.com/mpusz/mp-units.git
requires:
  - ms-gsl
prefer_system: .*
prefer_system_check: |
  #!/bin/bash -e
  printf '#include <mp-units/mp-units.h>\nint main(){}\n' | \
    c++ -std=c++20 -xc++ - \
    ${MP_UNITS_ROOT:+-I"$MP_UNITS_ROOT/include"} \
    ${MS_GSL_ROOT:+-I"$MS_GSL_ROOT/include"} \
    -o /dev/null
build_requires:
  - GCC-Toolchain
  - CMake
  - alibuild-recipe-tools
---
#!/bin/bash -e

cmake "$SOURCEDIR/src" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DCMAKE_CXX_STANDARD="${CMAKE_CXX_STANDARD:-20}" \
  -DCMAKE_PREFIX_PATH="$MS_GSL_ROOT" \
  -DMP_UNITS_API_CONTRACTS=MS-GSL
cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
# Our environment
set MP_UNITS_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path ROOT_INCLUDE_PATH \$MP_UNITS_ROOT/include
EoF
