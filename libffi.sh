package: libffi
version: v3.2.1
build_requires:
  - autotools
  - alibuild-recipe-tools
source: https://github.com/libffi/libffi
prepend_path:
  LD_LIBRARY_PATH: "$LIBFFI_ROOT/lib64"
---
#!/bin/bash -ex
rsync -a $SOURCEDIR/ .
autoreconf -ivf .
./configure --prefix=$INSTALLROOT
make ${JOBS:+-j $JOBS}
make install

[[ -d $INSTALLROOT/lib64 && ! -d $INSTALLROOT/lib ]] && ln -nfs lib64 $INSTALLROOT/lib

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EoF
prepend-path LD_LIBRARY_PATH \$PKG_ROOT/lib64
EoF
