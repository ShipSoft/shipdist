package: log4cpp
version: "1.1.6"
tag: "REL_1.1.6_Mar_12_2026"
source: https://git.code.sf.net/p/log4cpp/codegit
requires:
  - GCC-Toolchain
build_requires:
  - autotools
  - alibuild-recipe-tools
env:
  LOG4_ROOT: "$LOG4CPP_ROOT"
prefer_system_check: |
  ls $LOG4CPP_ROOT/include/ > /dev/null && \
  ls $LOG4CPP_ROOT/lib/ > /dev/null && \
  true
---
#!/bin/bash -ex
rsync -a $SOURCEDIR/* .
# automake's default GNU strictness requires a top-level README;
# the 1.1.6 tarball ships only README.md.
cp -f README.md README
./autogen.sh
./configure          --prefix=$INSTALLROOT  \
		     --enable-shared
make ${JOBS+-j$JOBS}
make install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
