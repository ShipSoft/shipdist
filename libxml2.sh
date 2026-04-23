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
autoreconf -i
./configure --disable-static \
            --prefix=$INSTALLROOT \
            --with-zlib="${ZLIB_ROOT}" --without-python

make ${JOBS+-j $JOBS}
make install
# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
