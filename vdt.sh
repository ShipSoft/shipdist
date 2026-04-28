package: vdt
version: "%(tag_basename)s"
tag: v0.4.6
source: https://github.com/dpiparo/vdt
build_requires:
  - CMake
  - "GCC-Toolchain:(?!osx)"
  - alibuild-recipe-tools
prefer_system_check: |
  printf "#include \"vdt/vdtMath.h\"\n" | c++ -xc++ - -c -M 2>&1
---
#!/bin/bash -e
cmake "$SOURCEDIR" -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE"

cmake --build . ${JOBS:+-j$JOBS} --target install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
