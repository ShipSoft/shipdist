package: zstd
version: "%(tag_basename)s"
tag: v1.5.7
source: https://github.com/facebook/zstd
build_requires:
  - GCC-Toolchain
  - CMake
  - ninja
  - alibuild-recipe-tools
prefer_system: (?!slc5)
prefer_system_check: |
  #!/bin/bash -e
  printf "#include <zstd.h>\n" | c++ -xc++ - -c -M 2>&1
---
#!/bin/bash -e
cmake $SOURCEDIR/build/cmake \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DZSTD_BUILD_TESTS=OFF \
  -DZSTD_BUILD_PROGRAMS=OFF \
  -DBUILD_TESTING=OFF

cmake --build . -- ${JOBS:+-j$JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > "$MODULEFILE"
