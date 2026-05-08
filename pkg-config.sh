package: pkg-config
version: "%(tag_basename)s"
tag: pkg-config-0.29.2
source: https://gitlab.freedesktop.org/pkg-config/pkg-config.git
build_requires:
  - GCC-Toolchain
  - alibuild-recipe-tools
prefer_system: .*
prefer_system_check: |
  pkg-config --version
---
#!/bin/bash -e
rsync -a --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR/" ./

if [[ -f configure.ac ]] && ! [[ -f configure ]]; then
  autoreconf -ivf
fi

./configure --disable-debug \
            --prefix="$INSTALLROOT" \
            --disable-host-tool \
            --with-internal-glib
make ${JOBS+-j $JOBS}
make install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
