package: FreeType
version: v2.10.1
tag: VER-2-10-1
source: https://github.com/freetype/freetype
requires:
  - zlib
build_requires:
  - "autotools:(slc6|slc7)"
  - alibuild-recipe-tools
prefer_system: (?!slc5)
prefer_system_check: |
  #!/bin/bash -e
  # shellcheck disable=SC2046
  if ! printf "#include <ft2build.h>\n" |
      c++ -xc++ - \
        $(freetype-config --cflags 2>/dev/null) \
        $(pkg-config freetype2 --cflags 2>/dev/null) \
        -c -M 2>&1; then
    printf "%s\n" \
      "FreeType is missing on your system." \
      " * RHEL-compatible: freetype freetype-devel" \
      " * Ubuntu-compatible: libfreetype6 libfreetype6-dev"
    exit 1
  fi
---
#!/bin/bash -ex
rsync -a --chmod=ug=rwX --exclude='**/.git' --delete --delete-excluded "$SOURCEDIR/" ./
type libtoolize && export LIBTOOLIZE=libtoolize
type glibtoolize && export LIBTOOLIZE=glibtoolize
sh autogen.sh
./configure --prefix="$INSTALLROOT"              \
            --with-png=no                        \
            ${ZLIB_ROOT:+--with-zlib="$ZLIB_ROOT"}

make ${JOBS:+-j$JOBS}
make install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"

mkdir -p etc/modulefiles
alibuild-generate-module --lib > etc/modulefiles/$PKGNAME
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
