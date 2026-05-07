package: GCC-Toolchain
version: "v15.2.0"
tag: "releases/gcc-15.2.0"
source: https://github.com/gcc-mirror/gcc.git
prepend_path:
  "LD_LIBRARY_PATH": "$GCC_TOOLCHAIN_ROOT/lib64"
build_requires:
  - yacc-like
  - make
  - alibuild-recipe-tools
prefer_system: .*
prefer_system_check: |
  set -e
  STRIPPED=${REQUESTED_VERSION#v}
  MAJOR=${STRIPPED%%.*}
  THRESHOLD=$((MAJOR * 10000))
  which gfortran || { echo "gfortran missing"; exit 1; }
  which gcc && test -f "$(dirname "$(which gcc)")"/c++ &&
    printf "%s\n" \
      "#define GCCVER ((__GNUC__*10000)+(__GNUC_MINOR__*100)+(__GNUC_PATCHLEVEL__))" \
      "#if (GCCVER < ${THRESHOLD})" \
      "#error \"Need at least GCC ${MAJOR}. Will compile our own.\"" \
      "#endif" |
    gcc -xc++ - -c -o /dev/null
---
#!/bin/bash -e

unset CXXFLAGS
unset CFLAGS

GCC_MAJOR=${PKGVERSION#v}
GCC_MAJOR=${GCC_MAJOR%%.*}
echo "Building GCC because no compatible version was found on the system. To skip this step, install GCC $GCC_MAJOR or newer. Make sure you have gfortran installed too."

case $ARCHITECTURE in
  *x86-64)
    MARCH='x86_64-unknown-linux-gnu'
  ;;
  *)
    MARCH=
  ;;
esac

rsync -a --exclude='**/.git' --delete --delete-excluded "$SOURCEDIR/" ./

# Fetch GMP, MPFR, MPC, ISL into the source tree (canonical upstream method).
# Requires network access during the build phase, same as the source git clone.
./contrib/download_prerequisites

# Test program used after install
cat > test.c <<EOF
#include <string.h>
#include <stdio.h>
int main(void) { printf("The answer is 42.\n"); }
EOF

mkdir build-gcc
pushd build-gcc
  ../configure --prefix="$INSTALLROOT"                          \
               ${MARCH:+--build=$MARCH --host=$MARCH}           \
               --enable-languages="c,c++,fortran${EXTRA_LANGS}" \
               --disable-multilib                               \
               --enable-lto                                     \
               --disable-nls
  make ${JOBS+-j $JOBS} bootstrap-lean MAKEINFO=":"
  make install MAKEINFO=":"
  hash -r

  # GCC creates c++, but not cc
  ln -nfs gcc "$INSTALLROOT/bin/cc"
  rm -rf "$INSTALLROOT/lib/pkg-config"

  rm -f $INSTALLROOT/lib/*.la \
        $INSTALLROOT/lib64/*.la
popd

# From now on, use own GCC
export PATH="$INSTALLROOT/bin:$PATH"
export LD_LIBRARY_PATH="$INSTALLROOT/lib64:$INSTALLROOT/lib:$LD_LIBRARY_PATH"
hash -r

# Smoke test the freshly installed compiler
which g++
g++ test.c
./a.out
rm -f a.out

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
# alibuild-generate-module has no --lib64 flag and does not read the YAML
# prepend_path key, but libstdc++.so.6 lives in lib64 — add it explicitly so
# `module load` sets LD_LIBRARY_PATH the same way `source setUp.sh` does.
cat >> "$MODULEFILE" <<EoF
prepend-path LD_LIBRARY_PATH \$PKG_ROOT/lib64
EoF
