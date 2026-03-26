package: Eigen3
version: 3.4.0
source: https://gitlab.com/libeigen/eigen.git
build_requires:
  - "GCC-Toolchain:(?!osx)"
  - CMake
  - alibuild-recipe-tools
prefer_system_check: |
  #!/bin/bash -e
  if [ -z "$EIGEN3_ROOT" ]; then
    for d in $(echo "$CMAKE_PREFIX_PATH" | tr : '\n'); do
      if [ -d "$d/include/eigen3/Eigen" ]; then
        export EIGEN3_ROOT="$d"
        break
      fi
    done
  fi
  printf "#include <Eigen/Core>\nint main(){}" | c++ -xc++ - -c -o /dev/null -I${EIGEN3_ROOT:+$EIGEN3_ROOT/include/eigen3}
---
#!/bin/bash -e
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "${MODULEFILE}"

cmake "$SOURCEDIR" -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"       \
                 -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE"      \
                 -DCMAKE_SKIP_RPATH=TRUE
cmake --build . -- ${JOBS:+-j$JOBS} install

# Modulefile
cat << EoF >> "$MODULEFILE"
# Our environment
set EIGEN3_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$EIGEN3_ROOT/bin
prepend-path LD_LIBRARY_PATH \$EIGEN3_ROOT/lib
prepend-path ROOT_INCLUDE_PATH \$EIGEN3_ROOT/include
EoF
