package: UUID
version: v2.27.1
tag: alice/v2.27.1
source: https://github.com/alisw/uuid
build_requires:
  - GCC-Toolchain
  - "autotools:(slc6|slc7)"
prepend_path:
  PKG_CONFIG_PATH: "$UUID_ROOT/share/pkgconfig"
---
rsync -av --delete --exclude '**/.git' "$SOURCEDIR/" .

perl -p -i -e 's/AM_GNU_GETTEXT_VERSION\(\[0\.18\.3\]\)/AM_GNU_GETTEXT_VERSION([0.18.2])/' configure.ac

autoreconf -ivf
./configure \
            "--libdir=$INSTALLROOT/lib"           \
            "--prefix=$INSTALLROOT"               \
            --disable-all-programs                \
            --disable-silent-rules                \
            --disable-tls                         \
            --disable-nls                         \
            --disable-rpath                       \
            --without-ncurses                     \
            --enable-libuuid
make ${JOBS:+-j$JOBS} libuuid.la libuuid/uuid.pc install-uuidincHEADERS
mkdir -p "$INSTALLROOT/lib" "$INSTALLROOT/share/pkgconfig"
cp -a libuuid/uuid.pc "$INSTALLROOT/share/pkgconfig"
cp -a .libs/libuuid.a* "$INSTALLROOT/lib"
cp -a .libs/libuuid.so* "$INSTALLROOT/lib"
rm -rf "$INSTALLROOT/man"
