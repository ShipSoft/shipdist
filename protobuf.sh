package: protobuf
version: "%(tag_basename)s"
tag: "v3.12.3"
source: https://github.com/google/protobuf
build_requires:
 - autotools
 - "GCC-Toolchain:(?!osx)"
 - alibuild-recipe-tools
prefer_system: "(?!slc5)"
prefer_system_check: |
  which protoc || { echo "protoc missing"; exit 1; }
  printf "#include \"google/protobuf/any.h\"\nint main(){}" | c++ -I$(brew --prefix protobuf)/include -Wno-deprecated-declarations -xc++ - -o /dev/null
---

rsync -av --delete --exclude="**/.git" $SOURCEDIR/ .
autoreconf -ivf
./configure --prefix="$INSTALLROOT"
make ${JOBS:+-j $JOBS}
make install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
