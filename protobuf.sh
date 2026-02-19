package: protobuf
version: "%(tag_basename)s"
tag: "v33.5"
source: https://github.com/protocolbuffers/protobuf
requires:
 - abseil
build_requires:
 - CMake
 - "GCC-Toolchain:(?!osx)"
 - alibuild-recipe-tools
 - ninja
prefer_system: "(?!slc5)"
prefer_system_check: |
  which protoc || { echo "protoc missing"; exit 1; }
  printf "#include \"google/protobuf/any.h\"\nint main(){}" | c++ -I$(brew --prefix protobuf)/include -Wno-deprecated-declarations -xc++ - -o /dev/null
prepend_path:
  PKG_CONFIG_PATH: "$PROTOBUF_ROOT/lib/pkgconfig"
  CMAKE_PREFIX_PATH: "$PROTOBUF_ROOT/lib/cmake"
---
#!/bin/bash -e

if [ -f $SOURCEDIR/cmake/CMakeLists.txt ]; then
  ALIBUILD_CMAKE_SOURCE_DIR=$SOURCEDIR/cmake
else
  ALIBUILD_CMAKE_SOURCE_DIR=$SOURCEDIR
fi

cmake -S "$ALIBUILD_CMAKE_SOURCE_DIR"                        \
    -G Ninja                                                 \
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"                    \
    -Dprotobuf_BUILD_TESTS=NO                                \
    -Dprotobuf_MODULE_COMPATIBLE=YES                         \
    -Dprotobuf_BUILD_SHARED_LIBS=OFF                         \
    -Dprotobuf_ABSL_PROVIDER=package                         \
    ${ABSEIL_ROOT:+-Dabsl_DIR=$ABSEIL_ROOT/lib/cmake/absl}   \
    -DCMAKE_INSTALL_LIBDIR=lib

cmake --build . -- ${JOBS:+-j$JOBS} install

# Fix header include issue
if [ -f "$INSTALLROOT/include/google/protobuf/io/coded_stream.h" ]; then
  sed -i.bak 's|absl/log/absl_log.h|absl/log/vlog_is_on.h|' $INSTALLROOT/include/google/protobuf/io/coded_stream.h
  rm -f $INSTALLROOT/include/google/protobuf/io/coded_stream.h.bak
fi

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
