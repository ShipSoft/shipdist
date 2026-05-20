package: gl2ps
version: "%(tag_basename)s"
tag: gl2ps_1_4_2
source: https://gitlab.onelab.info/gl2ps/gl2ps.git
requires:
  - opengl
  - zlib
  - libpng
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
prefer_system: (?!slc5)
prefer_system_check: |
  #!/bin/bash -e
  printf "#include <gl2ps.h>\n" | c++ -xc++ - -c -M 2>&1
---
#!/bin/bash -e
cmake $SOURCEDIR \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_INSTALL_LIBDIR=lib \
  ${ZLIB_ROOT:+-DZLIB_ROOT=$ZLIB_ROOT} \
  ${LIBPNG_ROOT:+-DPNG_ROOT=$LIBPNG_ROOT}

cmake --build . -- ${JOBS:+-j$JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > "$MODULEFILE"
