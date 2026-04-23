package: Random123
version: "%(tag_basename)s"
tag: v1.14.0
source: https://github.com/DEShawResearch/random123.git
build_requires:
  - GCC-Toolchain
  - alibuild-recipe-tools
---
#!/bin/bash -e

# Header-only library — just install the headers
mkdir -p "$INSTALLROOT/include"
cp -r "$SOURCEDIR/include/Random123" "$INSTALLROOT/include/"

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
# Our environment
set RANDOM123_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path ROOT_INCLUDE_PATH \$RANDOM123_ROOT/include
EoF
