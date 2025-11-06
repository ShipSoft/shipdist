package: DD4hep
version: "%(tag_basename)s"
tag: v01-33
source: https://github.com/AIDASoft/DD4hep
requires:
  - ROOT
  - boost
  - GEANT4
  - XercesC
  - TBB
build_requires:
  - CMake
env:
  DD4HEP: "$DD4HEP_ROOT"
  DD4hepINSTALL: "$DD4HEP_ROOT"
prepend_path:
  ROOT_INCLUDE_PATH: "$DD4HEP_ROOT/include"
  PATH: "$DD4HEP_ROOT/bin"
  LD_LIBRARY_PATH: "$DD4HEP_ROOT/lib"
---
#!/bin/bash -e

# Fix Geant4 exported flags to prevent concatenation bugs in DD4hep's CMake
# Add trailing space to Geant4_CXX_FLAGS and leading space to build-type-specific flags
# This ensures proper separation when DD4hep concatenates them
if [ -n "$GEANT4_ROOT" ]; then
  find "$GEANT4_ROOT" -name "Geant4Config.cmake" -exec sed -i.bak \
    -e 's/set(Geant4_CXX_FLAGS "\(.*\)")/set(Geant4_CXX_FLAGS "\1 ")/' \
    -e 's/set(Geant4_CXX_FLAGS_RELEASE "\(.*\)")/set(Geant4_CXX_FLAGS_RELEASE " \1")/' \
    -e 's/set(Geant4_CXX_FLAGS_DEBUG "\(.*\)")/set(Geant4_CXX_FLAGS_DEBUG " \1")/' \
    -e 's/set(Geant4_CXX_FLAGS_RELWITHDEBINFO "\(.*\)")/set(Geant4_CXX_FLAGS_RELWITHDEBINFO " \1")/' \
    -e 's/set(Geant4_CXX_FLAGS_MINSIZEREL "\(.*\)")/set(Geant4_CXX_FLAGS_MINSIZEREL " \1")/' \
    {} \;
fi

cmake "$SOURCEDIR" \
      -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE} \
      ${CMAKE_CXX_STANDARD:+-DCMAKE_CXX_STANDARD=$CMAKE_CXX_STANDARD} \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_TESTING=OFF \
      -DDD4HEP_USE_XERCESC=ON \
      -DDD4HEP_USE_GEANT4=ON \
      -DDD4HEP_USE_TBB=ON \
      -DDD4HEP_USE_EDM4HEP=OFF \
      -DDD4HEP_USE_LCIO=OFF \
      -DDD4HEP_USE_HEPMC3=OFF \
      -DDD4HEP_BUILD_EXAMPLES=OFF \
      -DDD4HEP_SET_RPATH=OFF \
      -DTBB_IMPORTED_TARGETS="TBB::tbb" \
      ${BOOST_ROOT:+-DBoost_ROOT=$BOOST_ROOT} \
      ${ROOT_ROOT:+-DROOT_DIR=$ROOT_ROOT} \
      ${GEANT4_ROOT:+-DGeant4_DIR=$GEANT4_ROOT} \
      ${XERCESC_ROOT:+-DXercesC_DIR=$XERCESC_ROOT} \
      ${TBB_ROOT:+-DTBB_DIR=$TBB_ROOT/lib/cmake/TBB}

cmake --build . ${JOBS:+-j$JOBS}
cmake --install .

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EoF
prepend-path ROOT_INCLUDE_PATH \$PKG_ROOT/include
prepend-path CMAKE_PREFIX_PATH \$PKG_ROOT
setenv DD4HEP \$PKG_ROOT
setenv DD4hepINSTALL \$PKG_ROOT
EoF
