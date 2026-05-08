package: autoconf
version: "%(tag_basename)s"
tag: v2.72
source: https://git.savannah.gnu.org/git/autoconf.git
requires:
  - m4
build_requires:
  - GCC-Toolchain
  - alibuild-recipe-tools
prefer_system: .*
prefer_system_check: |
  autoconf --version
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
