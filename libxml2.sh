package: libxml2
version: "%(tag_basename)s"
tag: v2.9.3
build_requires:
  - "autotools:(slc6|slc7)"
  - zlib
  - GCC-Toolchain
  - alibuild-recipe-tools
source: https://github.com/alisw/libxml2.git
prefer_system: "(?!slc5)"
prefer_system_check: |
  #!/bin/bash -e
  if ! xml2-config --version; then
    printf "%s\n" \
      "libxml2 not found." \
      " * RHEL-compatible: libxml2 libxml2-devel" \
      " * Ubuntu-compatible: libxml2 libxml2-dev"
    exit 1
  fi
---
#!/bin/sh
echo "Building ALICE libxml. To avoid this install libxml development package."
rsync -a $SOURCEDIR/ ./

# libxml2 v2.9.3 has K&R-style empty () declarations in threads.c that GCC 15
# rejects under its default C23 dialect. Force gnu17 until the recipe is bumped
# to a C23-clean upstream release.
export CFLAGS="${CFLAGS} -std=gnu17"

autoreconf -i
./configure --disable-static \
            --prefix=$INSTALLROOT \
            --with-zlib="${ZLIB_ROOT}" --without-python

make ${JOBS+-j $JOBS}
make install
# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
