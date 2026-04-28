package: PCRE2
version: "%(tag_basename)s"
tag: pcre2-10.44
source: https://github.com/PCRE2Project/pcre2
build_requires:
  - "GCC-Toolchain:(?!osx)"
  - CMake
  - alibuild-recipe-tools
prefer_system: (?!slc5)
prefer_system_check: |
  printf "#include \"pcre2.h\"\n" | c++ -xc++ -DPCRE2_CODE_UNIT_WIDTH=8 - -c -M 2>&1
---
#!/bin/bash -e
cmake "$SOURCEDIR" -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
                   -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
                   -DPCRE2_SUPPORT_UNICODE=ON             \
                   -DPCRE2_BUILD_PCRE2_8=ON               \
                   -DPCRE2_BUILD_PCRE2_16=OFF             \
                   -DPCRE2_BUILD_PCRE2_32=OFF

cmake --build . ${JOBS:+-j$JOBS} --target install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
