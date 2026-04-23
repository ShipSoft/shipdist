package: boost
version: "%(tag_basename)s"
tag: "v1.83.0"
source: https://github.com/alisw/boost.git
requires:
  - GCC-Toolchain
  - Python
build_requires:
  - lzma
  - bz2
  - alibuild-recipe-tools
prepend_path:
  ROOT_INCLUDE_PATH: "$BOOST_ROOT/include"
prefer_system: ".*"
prefer_system_check: |
 printf "#include \"boost/version.hpp\"\n# if (BOOST_VERSION < 108800)\n#error \"Cannot use system's boost. Boost >= 1.88.00 required.\"\n#endif\nint main(){}" \
 | gcc -I$BOOST_ROOT/include -xc++ - -o /dev/null
---
if [[ $CXXSTD && $CXXSTD -ge 17 ]]; then
  # Use C++17: https://github.com/boostorg/system/issues/26#issuecomment-413631998
  CXXSTD=17
fi

TMPB2=$BUILDDIR/tmp-boost-build
TOOLSET=gcc

rsync -a $SOURCEDIR/ $BUILDDIR/
cd $BUILDDIR/tools/build
# This is to work around an issue in boost < 1.70 where the include path misses
# the ABI suffix. E.g. ../include/python3 rather than ../include/python3m.
# This is causing havok on different combinations of Ubuntu / Anaconda
# installations.
bash bootstrap.sh $TOOLSET
PYINCPATH=$(python3 -c 'import sysconfig; print(sysconfig.get_path("include"))')
export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH:+$CPLUS_INCLUDE_PATH:}$PYINCPATH"
mkdir -p $TMPB2
./b2 install --prefix=$TMPB2
export PATH=$TMPB2/bin:$PATH
cd $BUILDDIR
b2 -q                                            \
   -d2                                           \
   ${JOBS+-j $JOBS}                              \
   --prefix=$INSTALLROOT                         \
   --build-dir=build-boost                       \
   --disable-icu                                 \
   --without-context                             \
   --without-coroutine                           \
   --without-graph                               \
   --without-graph_parallel                      \
   --without-locale                              \
   --without-math                                \
   --without-mpi                                 \
   --without-python                              \
   --without-wave                                \
   --debug-configuration                         \
   -sNO_ZSTD=1                                   \
   ${BZ2_ROOT:+-sBZIP2_INCLUDE="$BZ2_ROOT/include"}  \
   ${BZ2_ROOT:+-sBZIP2_LIBPATH="$BZ2_ROOT/lib"}      \
   ${ZLIB_ROOT:+-sZLIB_INCLUDE="$ZLIB_ROOT/include"} \
   ${ZLIB_ROOT:+-sZLIB_LIBPATH="$ZLIB_ROOT/lib"}     \
   ${LZMA_ROOT:+-sLZMA_INCLUDE="$LZMA_ROOT/include"} \
   ${LZMA_ROOT:+-sLZMA_LIBPATH="$LZMA_ROOT/lib"}     \
   toolset=$TOOLSET                              \
   link=shared                                   \
   threading=multi                               \
   variant=release                               \
   ${CXXSTD:+cxxstd=$CXXSTD}                     \
   install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<\EoF
prepend-path ROOT_INCLUDE_PATH $PKG_ROOT/include
EoF
