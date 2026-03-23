package: CLHEP
version: "2.2.0.8"
tag: CLHEP_2_2_0_8
source: https://github.com/alisw/clhep
build_requires:
  - CMake
  - "GCC-Toolchain:(?!osx)"
prefer_system_check: |
  #!/bin/bash -e
  pkg-config --exists clhep
---
#!/bin/sh
cmake $SOURCEDIR \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"

make ${JOBS+-j $JOBS}
make install
