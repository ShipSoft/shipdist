package: GEANT3
version: "%(tag_basename)s"
tag: v4-5
requires:
  - ROOT
  - VMC
build_requires:
  - CMake
  - "Xcode:(osx.*)"
source: https://github.com/vmc-project/geant3
prepend_path:
  LD_LIBRARY_PATH: "$GEANT3_ROOT/lib64"
  ROOT_INCLUDE_PATH: "$GEANT3_ROOT/include/TGeant3"
prefer_system_check: |
  #!/bin/bash -e
  ls $GEANT3_ROOT/ > /dev/null && \
  ls $GEANT3_ROOT/include > /dev/null && \
  ls $GEANT3_ROOT/include/TGeant3 > /dev/null && \
  ls $GEANT3_ROOT/include/TGeant3/TGeant3.h > /dev/null && \
  (ls $GEANT3_ROOT/lib64/libgeant321.so > /dev/null 2>&1 || ls $GEANT3_ROOT/lib/libgeant321.so > /dev/null 2>&1) && \
  true
---
#!/bin/bash -e
FVERSION=`gfortran --version | grep -i fortran | sed -e 's/.* //' | cut -d. -f1`
SPECIALFFLAGS=""
if [ $FVERSION -ge 10 ]; then
   echo "Fortran version $FVERSION"
   SPECIALFFLAGS=1
fi

# GEANT3's minicern uses K&R-style C declarations (e.g. `char *fchtak()`)
# that break with GCC 15's default -std=gnu23. Pass -std=gnu11 to restore
# the old "unspecified arguments" semantics. Harmless on older GCC versions.
cmake $SOURCEDIR -DCMAKE_INSTALL_PREFIX=$INSTALLROOT      \
                 -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE     \
                 ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}  \
                 -DCMAKE_SKIP_RPATH=TRUE \
		 -DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
                 ${SPECIALFFLAGS:+-DCMAKE_Fortran_FLAGS="-fallow-argument-mismatch -fallow-invalid-boz -fno-tree-loop-distribute-patterns"} \
                 -DCMAKE_C_FLAGS="-std=gnu11"
make ${JOBS:+-j $JOBS} install

[[ ! -d $INSTALLROOT/lib64 ]] && ln -sf lib $INSTALLROOT/lib64

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
module load BASE/1.0 ROOT/$ROOT_VERSION-$ROOT_REVISION VMC/$VMC_VERSION-$VMC_REVISION
# Our environment
set GEANT3_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv GEANT3_ROOT \$GEANT3_ROOT
setenv GEANT3DIR \$GEANT3_ROOT
setenv G3SYS \$GEANT3_ROOT
prepend-path LD_LIBRARY_PATH \$GEANT3_ROOT/lib64
prepend-path ROOT_INCLUDE_PATH \$GEANT3_ROOT/include/TGeant3
EoF
