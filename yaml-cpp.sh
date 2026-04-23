package: yaml-cpp
version: "%(tag_basename)s"
tag: yaml-cpp-0.6.3
source: https://github.com/jbeder/yaml-cpp
requires:
  - boost
build_requires:
  - CMake
  - alibuild-recipe-tools
prefer_system: (?!slc5)
prefer_system_check: |
  pkg-config --atleast-version=0.6.2 yaml-cpp &&
    printf "#include \"yaml-cpp/yaml.h\"\n" |
    c++ -std=c++17 -I$BOOST_ROOT/include -xc++ - -c -o /dev/null
---
#!/bin/sh
cmake $SOURCEDIR                                         \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"             \
  -DBUILD_SHARED_LIBS=YES                                \
  ${BOOST_ROOT:+-DBOOST_ROOT:PATH="$BOOST_ROOT"}         \
  ${BOOST_ROOT:+-DBoost_DIR:PATH="$BOOST_ROOT"}          \
  ${BOOST_ROOT:+-DBoost_INCLUDE_DIR:PATH="$BOOST_ROOT/include"}  \
  -DCMAKE_SKIP_RPATH=YES                                 \
  -DYAML_CPP_BUILD_TESTS=NO                              \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DSKIP_INSTALL_FILES=1

make ${JOBS+-j $JOBS} install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
