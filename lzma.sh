package: lzma
version: "%(tag_basename)s"
tag: "v5.2.3"
source: https://github.com/alisw/liblzma
build_requires:
  - autotools
  - GCC-Toolchain
  - rsync
  - alibuild-recipe-tools
prefer_system: "(?!slc5)"
prefer_system_check: |
  printf "#include <lzma.h>\n" | c++ -xc++ - -c -M 2>&1
---
rsync -a --delete --exclude '**/.git' --delete-excluded $SOURCEDIR/ ./
./autogen.sh
./configure CFLAGS="$CFLAGS -fPIC -Ofast" \
            --prefix="$INSTALLROOT"       \
            --disable-shared              \
            --enable-static               \
            --disable-nls                 \
            --disable-rpath               \
            --disable-dependency-tracking \
            --disable-doc
make ${JOBS+-j $JOBS} install
rm -f "$INSTALLROOT"/lib/*.la

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
