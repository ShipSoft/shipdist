package: OpenSSL
version: v1.1.1m
tag: OpenSSL_1_1_1m
source: https://github.com/openssl/openssl
prefer_system: (?!slc5|slc6)
prefer_system_check: |
  #!/bin/bash -e
  case $(uname) in
    Darwin) prefix=$(brew --prefix openssl@1.1); [ -d "$prefix" ] ;;
    *) prefix= ;;
  esac
  cc -x c - ${prefix:+"-I$prefix/include"} -c -o /dev/null <<\EOF
  #include <openssl/bio.h>
  #include <openssl/opensslv.h>
  #if OPENSSL_VERSION_NUMBER < 0x10101000L
  #error "System's OpenSSL cannot be used: we need OpenSSL >= 1.1.1 for the Python ssl module. We are going to compile our own version."
  #endif
  int main() { }
  EOF
build_requires:
  - zlib
  - alibuild-recipe-tools
  - "GCC-Toolchain:(?!osx)"
---
#!/bin/bash -e

rsync -av --delete --exclude="**/.git" $SOURCEDIR/ .
case ${PKG_VERSION} in
  v1.1*)
    OPTS=""
    OPENSSLDIRPREFIX="" ;;
  *)
    OPTS="no-krb5"
    OPENSSLDIRPREFIX="etc/ssl"
  ;;
esac

./config --prefix="$INSTALLROOT"                   \
         --openssldir="$INSTALLROOT/$OPENSSLDIRPREFIX"       \
         --libdir=lib                              \
         zlib                                      \
         no-idea                                   \
         no-mdc2                                   \
         no-rc5                                    \
         no-asm                                    \
         ${OPTS}                                   \
         shared                                    \
         -fno-strict-aliasing                      \
         -L"$INSTALLROOT/lib"                      \
         -Wa,--noexecstack
make depend
make  # don't ever try to build in multicore
make install_sw # no not install man pages

# Remove static libraries and pkgconfig
rm -rf $INSTALLROOT/lib/pkgconfig \
       $INSTALLROOT/lib/*.a

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 ${ZLIB_VERSION:+zlib/$ZLIB_VERSION-$ZLIB_REVISION} ${GCC_TOOLCHAIN_ROOT:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
setenv OPENSSL_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(OPENSSL_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(OPENSSL_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(OPENSSL_ROOT)/lib")
EoF
