package: googletest
version: "1.17.0"
source: https://github.com/google/googletest
tag: v1.17.0
build_requires:
 - "GCC-Toolchain:(?!osx)"
 - CMake
prefer_system_check: |
  #!/bin/bash -e
  ls $GOOGLETEST_ROOT/ > /dev/null && \
  ls $GOOGLETEST_ROOT/include > /dev/null && \
  ls $GOOGLETEST_ROOT/include/gmock > /dev/null && \
  ls $GOOGLETEST_ROOT/include/gtest > /dev/null && \
  ls $GOOGLETEST_ROOT/lib/libgmock.a > /dev/null && \
  ls $GOOGLETEST_ROOT/lib/libgmock_main.a > /dev/null && \
  ls $GOOGLETEST_ROOT/lib/libgtest.a > /dev/null && \
  ls $GOOGLETEST_ROOT/lib/libgtest_main.a > /dev/null && \
  true
---
#!/bin/sh
cmake $SOURCEDIR                           \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

make ${JOBS+-j $JOBS}
make install
