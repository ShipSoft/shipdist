package: googletest
version: "1.17.0"
source: https://github.com/google/googletest
tag: v1.17.0
build_requires:
 - "GCC-Toolchain:(?!osx)"
 - CMake
prefer_system_check: |
  #!/bin/bash -e
  pkg-config --exists gtest gmock
---
#!/bin/sh
cmake $SOURCEDIR                           \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

make ${JOBS+-j $JOBS}
make install
