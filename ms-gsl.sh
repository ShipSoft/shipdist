package: ms-gsl
version: "%(tag_basename)s"
tag: v4.2.1
source: https://github.com/microsoft/GSL.git
prefer_system: .*
prefer_system_check: |
  #!/bin/bash -e
  printf '#include <gsl/gsl>\nint main(){}\n' | \
    c++ -std=c++20 -xc++ - \
    ${MS_GSL_ROOT:+-I"$MS_GSL_ROOT/include"} \
    -o /dev/null
build_requires:
  - GCC-Toolchain
  - CMake
  - alibuild-recipe-tools
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DGSL_TEST=OFF
cmake --build . -- ${JOBS:+-j$JOBS} install

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
# Our environment
set MS_GSL_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path ROOT_INCLUDE_PATH \$MS_GSL_ROOT/include
EoF
