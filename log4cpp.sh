package: log4cpp
source: https://git.code.sf.net/p/log4cpp/codegit
version: 1b9f8f7c031d6947c7468d54bc1da4b2f414558d
requires:
  - GCC-Toolchain:(?!osx)
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
./autogen.sh
./configure          --prefix=$INSTALLROOT  \
		     --enable-shared
make ${JOBS+-j$JOBS}
make install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
