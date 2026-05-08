package: gettext
version: "%(tag_basename)s"
tag: v0.23.1
source: https://git.savannah.gnu.org/git/gettext.git
build_requires:
  - autoconf
  - automake
  - libtool
  - GCC-Toolchain
  - alibuild-recipe-tools
prefer_system: .*
prefer_system_check: |
  autopoint --version
---
#!/bin/bash -e
rsync -a --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR/" ./

if [[ -x ./bootstrap ]]; then
  ./bootstrap
elif [[ -f configure.ac ]]; then
  autoreconf -ivf
fi

./configure --prefix="$INSTALLROOT" \
            --without-xz \
            --without-bzip2 \
            --disable-curses \
            --disable-openmp \
            --enable-relocatable \
            --disable-rpath \
            --disable-nls \
            --disable-native-java \
            --disable-acl \
            --disable-java \
            --disable-dependency-tracking \
            --without-emacs \
            --disable-silent-rules
make ${JOBS+-j $JOBS}
make install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
