package: automake
version: "%(tag_basename)s"
tag: v1.17
source: https://git.savannah.gnu.org/git/automake.git
requires:
  - m4
  - autoconf
build_requires:
  - GCC-Toolchain
  - alibuild-recipe-tools
prefer_system: .*
prefer_system_check: |
  automake --version
---
#!/bin/bash -e
rsync -a --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR/" ./

if [[ -x ./bootstrap ]]; then
  ./bootstrap
elif [[ -f configure.ac ]]; then
  autoreconf -ivf
fi

./configure --prefix="$INSTALLROOT"
make MAKEINFO=true ${JOBS+-j $JOBS}
make MAKEINFO=true install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
