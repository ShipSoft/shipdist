package: libtool
version: "%(tag_basename)s"
tag: v2.5.4
source: https://git.savannah.gnu.org/git/libtool.git
requires:
  - m4
build_requires:
  - autoconf
  - automake
  - GCC-Toolchain
  - alibuild-recipe-tools
prefer_system: .*
prefer_system_check: |
  libtool --version
---
#!/bin/bash -e
rsync -a --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR/" ./

if [[ -x ./bootstrap ]]; then
  ./bootstrap
elif [[ -f configure.ac ]]; then
  autoreconf -ivf
fi

./configure --disable-dependency-tracking --prefix="$INSTALLROOT" --enable-ltdl-install
make ${JOBS+-j $JOBS}
make install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
