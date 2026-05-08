package: m4
version: "%(tag_basename)s"
tag: v1.4.19
source: https://git.savannah.gnu.org/git/m4.git
build_requires:
  - GCC-Toolchain
  - alibuild-recipe-tools
prefer_system: .*
prefer_system_check: |
  m4 --version
---
#!/bin/bash -e
rsync -a --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR/" ./

if [[ -x ./bootstrap ]]; then
  ./bootstrap
elif [[ -f configure.ac ]]; then
  autoreconf -ivf
fi

./configure --disable-dependency-tracking --prefix="$INSTALLROOT"
make ${JOBS+-j $JOBS}
make install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
