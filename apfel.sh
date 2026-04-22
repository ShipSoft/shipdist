package: apfel
version: 3.0.7
tag: 3.0.7
source: https://github.com/scarrazza/apfel.git
requires:
  - lhapdf
build_requires:
  - CMake
  - alibuild-recipe-tools
env:
  LD_LIBRARY_PATH: "$LD_LIBRARY_PATH:$APFEL_ROOT/lib"
prefer_system_check: |
  #!/bin/bash -e
  apfel-config --version > /dev/null
  printf '#include "APFEL/APFEL.h"\nint main(){}' | c++ -xc++ - -c -o /dev/null
---
#!/bin/bash -ex

cmake -S $SOURCEDIR -B .                                        \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                       \
      ${CMAKE_GENERATOR:+-G "$CMAKE_GENERATOR"}                 \
      ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE} \
      -DCMAKE_INSTALL_LIBDIR=lib                                \
      -DAPFEL_DOWNLOAD_PDFS=OFF                                 \
      -DAPFEL_ENABLE_TESTS=OFF                                  \
      -DAPFEL_ENABLE_PYTHON=OFF

cmake --build . -- ${JOBS:+-j$JOBS} install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
