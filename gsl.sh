package: GSL
version: "v2.8"
tag: "v2.8"
source: https://github.com/alisw/gsl
requires:
  - GCC-Toolchain
build_requires:
  - "autotools:(slc6|slc7)"
  - alibuild-recipe-tools
prefer_system: (?!slc5)
prefer_system_check: |
  #!/bin/bash -e
  printf "%s\n" \
    "#include \"gsl/gsl_version.h\"" \
    "#define GSL_V GSL_MAJOR_VERSION * 100 + GSL_MINOR_VERSION" \
    "# if (GSL_V < 116)" \
    "#error \"Cannot use system GSL. Need >= 1.16.\"" \
    "#endif" \
    "int main(){}" |
    cc -xc - ${GSL_ROOT:+-I$GSL_ROOT/include} -c -o /dev/null
---
#!/bin/bash -e
rsync -a --chmod=ug=rwX --exclude .git --delete-excluded $SOURCEDIR/ $BUILDDIR/
# Do not build documentation
sed -i.bak -e "s/doc//" Makefile.am
sed -i.bak -e "s|doc/Makefile||" configure.ac
autoreconf -f -v -i
./configure --prefix="$INSTALLROOT" \
            --enable-maintainer-mode
make ${JOBS:+-j$JOBS}
make ${JOBS:+-j$JOBS} install
rm -fv $INSTALLROOT/lib/*.la
# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > $MODULEFILE
cat >> "$MODULEFILE" <<EoF
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
EoF
