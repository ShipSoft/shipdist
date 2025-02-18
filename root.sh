package: ROOT
version: "%(tag_basename)s%(defaults_upper)s"
tag: "v6-30-08"
source: https://github.com/root-project/root
requires:
- GSL
- opengl:(?!osx)
- Xdevel:(?!osx)
- FreeType:(?!osx)
- Python-modules
- zlib
- libxml2
- "OpenSSL:(?!osx)"
- "osx-system-openssl:(osx.*)"
- XRootD
- pythia
- pythia6
build_requires:
- CMake
- "Xcode:(osx.*)"
- libxml2
- Python
env:
  ROOTSYS: "$ROOT_ROOT"
prepend_path:
  PYTHONPATH: "$ROOTSYS/lib"
incremental_recipe: |
  make ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
  cd $INSTALLROOT/test
  env PATH=$INSTALLROOT/bin:$PATH LD_LIBRARY_PATH=$INSTALLROOT/lib:$LD_LIBRARY_PATH DYLD_LIBRARY_PATH=$INSTALLROOT/lib:$DYLD_LIBRARY_PATH make ${JOBS+-j$JOBS}
---
#!/bin/bash -e
unset ROOTSYS

COMPILER_CC=cc
COMPILER_CXX=c++
COMPILER_LD=c++

[[ "$CXXFLAGS" == *'-std=c++11'* ]] && CMAKE_CXX_STANDARD=11 || true
[[ "$CXXFLAGS" == *'-std=c++14'* ]] && CMAKE_CXX_STANDARD=14 || true
[[ "$CXXFLAGS" == *'-std=c++17'* ]] && CMAKE_CXX_STANDARD=17 || true

case $ARCHITECTURE in
  osx*)
    ENABLE_COCOA=1
    COMPILER_CC=clang
    COMPILER_CXX=clang++
    COMPILER_LD=clang
    [[ ! $GSL_ROOT ]] && GSL_ROOT=`brew --prefix gsl`
    [[ ! $OPENSSL_ROOT ]] && SYS_OPENSSL_ROOT=`brew --prefix openssl`
  ;;
esac

#If pythia6 is not provided, perform late linking
if [[ -z $PYTHIA6_ROOT ]]
then
    PYHIA6_LATE=TRUE
fi

# Normal ROOT build.
cmake $SOURCEDIR \
-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE                      \
-DCMAKE_INSTALL_PREFIX=$INSTALLROOT                       \
${XROOTD_ROOT:+-DXROOTD_ROOT_DIR=$XROOTD_ROOT}            \
-DCMAKE_CXX_STANDARD=$CMAKE_CXX_STANDARD                  \
-Dbuiltin_freetype=OFF                                    \
-Dbuiltin_pcre=ON                                         \
${ENABLE_COCOA:+-Dcocoa=ON}                               \
-DCMAKE_CXX_COMPILER=$COMPILER_CXX                        \
-DCMAKE_C_COMPILER=$COMPILER_CC                           \
-DCMAKE_LINKER=$COMPILER_LD                               \
${GCC_TOOLCHAIN_VERSION:+-DCMAKE_EXE_LINKER_FLAGS="-L$GCC_TOOLCHAIN_ROOT/lib64"} \
${SYS_OPENSSL_ROOT:+-DOPENSSL_ROOT=$SYS_OPENSSL_ROOT}     \
${SYS_OPENSSL_ROOT:+-DOPENSSL_INCLUDE_DIR=$SYS_OPENSSL_ROOT/include} \
${GSL_ROOT:+-DGSL_DIR=$GSL_ROOT}                          \
${PYTHIA_ROOT:+-DPYTHIA8_DIR=$PYTHIA_ROOT}                \
${PYTHIA_ROOT:+-Dpythia8=ON}                \
${PYTHIA6_ROOT:+-DPYTHIA6_LIBRARY=$PYTHIA6_ROOT/lib/libpythia6.so} \
${PYTHIA6_ROOT:+-Dpythia6=ON}                             \
${PYTHIA6_LATE:+-Dpythia6_nolink=ON}                      \
-Dmathmore=ON \
-Dsoversion=ON                                            \
-Dshadowpw=OFF                                            \
-Dbuiltin_vdt=ON                                          \
${PYTHON_ROOT:+-DPYTHON_EXECUTABLE=$PYTHONHOME/bin/python} \
${PYTHON_ROOT:+-DPYTHON_INCLUDE_DIR=$PYTHONHOME/include/python3.6m} \
${PYTHON_ROOT:+-DPYTHON_LIBRARY=$PYTHONHOME/lib/libpython3.6m.so} \
-DCMAKE_PREFIX_PATH="$FREETYPE_ROOT;$SYS_OPENSSL_ROOT;$GSL_ROOT;$PYTHON_ROOT;$PYTHON_MODULES_ROOT"
FEATURES="builtin_pcre xml ssl opengl http gdml mathmore ${PYTHIA_ROOT:+pythia8}
    pythia6 roofit soversion vdt ${XROOTD_ROOT:+xrootd}
    ${ENABLE_COCOA:+builtin_freetype}"
NO_FEATURES="${FREETYPE_ROOT:+builtin_freetype}"

# Check if all required features are enabled
bin/root-config --features
for FEATURE in $FEATURES; do
  bin/root-config --has-$FEATURE | grep -q yes
done
for FEATURE in $NO_FEATURES; do
  bin/root-config --has-$FEATURE | grep -q no
done

cmake --build . ${JOBS+-j$JOBS} --target install
[[ -d $INSTALLROOT/test ]] && ( cd $INSTALLROOT/test && env PATH=$INSTALLROOT/bin:$PATH LD_LIBRARY_PATH=$INSTALLROOT/lib:$LD_LIBRARY_PATH DYLD_LIBRARY_PATH=$INSTALLROOT/lib:$DYLD_LIBRARY_PATH make ${JOBS+-j$JOBS} )

# Modulefile
mkdir -p etc/modulefiles
cat > etc/modulefiles/$PKGNAME <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 ${GCC_TOOLCHAIN_VERSION:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}     \\
                     ${GSL_VERSION:+GSL/$GSL_VERSION-$GSL_REVISION}                                             \\
                     ${XROOTD_VERSION:+XRootD/$XROOTD_VERSION-$XROOTD_REVISION}                                 \\
                     ${FREETYPE_VERSION:+FreeType/$FREETYPE_VERSION-$FREETYPE_REVISION}                         \\
                     ${PYTHON_VERSION:+Python/$PYTHON_VERSION-$PYTHON_REVISION}                                 \\
                     ${PYTHON_MODULES_VERSION:+Python-modules/$PYTHON_MODULES_VERSION-$PYTHON_MODULES_REVISION} \\
                     ${PYTHIA_VERSION:+pythia/$PYTHIA_VERSION-$PYTHIA_REVISION}                                 \\
                     ${PYTHIA6_VERSION:+pythia6/$PYTHIA6_VERSION-$PYTHIA6_REVISION}
# Our environment
setenv ROOT_RELEASE \$version
setenv ROOT_BASEDIR \$::env(BASEDIR)/$PKGNAME
setenv ROOTSYS \$::env(ROOT_BASEDIR)/\$::env(ROOT_RELEASE)
prepend-path PYTHONPATH \$::env(ROOTSYS)/lib
prepend-path PATH \$::env(ROOTSYS)/bin
prepend-path LD_LIBRARY_PATH \$::env(ROOTSYS)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(ROOTSYS)/lib")
EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
