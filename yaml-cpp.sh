package: yaml-cpp
version: "%(tag_basename)s"
tag: 0.8.0
source: https://github.com/jbeder/yaml-cpp
build_requires:
  - CMake
  - alibuild-recipe-tools
prefer_system: (?!slc5)
prefer_system_check: |
  REQUESTED_VERSION=${REQUESTED_VERSION#v}
  pkg-config --atleast-version=$REQUESTED_VERSION yaml-cpp &&
    printf "#include \"yaml-cpp/yaml.h\"\n" |
    c++ -std=c++17 -xc++ - -c -o /dev/null
---
#!/bin/sh

cmake $SOURCEDIR                                         \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"             \
  -DBUILD_SHARED_LIBS=YES                                \
  -DCMAKE_SKIP_RPATH=YES                                 \
  -DYAML_CPP_BUILD_TESTS=NO                              \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5                     \
  -DSKIP_INSTALL_FILES=1

make ${JOBS+-j $JOBS} install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
