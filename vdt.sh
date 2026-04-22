package: vdt
version: "%(tag_basename)s"
tag: v0.4.6
source: https://github.com/dpiparo/vdt
build_requires:
  - CMake
  - "GCC-Toolchain:(?!osx)"
prefer_system_check: |
  printf "#include \"vdt/vdtMath.h\"\n" | c++ -xc++ - -c -M 2>&1
---
#!/bin/bash -e
cmake "$SOURCEDIR" -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE"

cmake --build . ${JOBS:+-j$JOBS} --target install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p "$MODULEDIR"
cat > "$MODULEDIR/$PKGNAME" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 ${GCC_TOOLCHAIN_REVISION:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
set VDT_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$VDT_ROOT/lib
EoF
