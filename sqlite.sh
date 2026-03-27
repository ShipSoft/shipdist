package: sqlite
source: https://github.com/sqlite/sqlite
version: "%(tag_basename)s%(defaults_upper)s"
tag: "version-3.49.1"
prefer_system: (?!slc5)
prefer_system_check: |
  printf '#include <sqlite3.h>\nint main(){}\n' | cc -xc - -lsqlite3 -o /dev/null
build_requires:
  - "GCC-Toolchain:(?!osx)"
  - autotools
  - alibuild-recipe-tools
---
#!/bin/bash -ex
rsync -av $SOURCEDIR/ ./
autoreconf -ivf
./configure --disable-tcl --disable-readline --disable-static --prefix=$INSTALLROOT
make
make install
rm -f $INSTALLROOT/lib/*.la
rm -rf $INSTALLROOT/share

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
setenv SQLITE_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
EoF
