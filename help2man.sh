package: help2man
version: "1.49.3"
build_requires:
  - GCC-Toolchain
  - alibuild-recipe-tools
prefer_system: .*
prefer_system_check: |
  help2man --version
---
#!/bin/bash -e

# help2man has no public git repo; download release tarball from GNU FTP
curl -sLO "https://ftp.gnu.org/gnu/help2man/help2man-${PKGVERSION}.tar.xz"
tar xf "help2man-${PKGVERSION}.tar.xz"
cd "help2man-${PKGVERSION}"

./configure --prefix="$INSTALLROOT"
make ${JOBS+-j $JOBS}
make install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
