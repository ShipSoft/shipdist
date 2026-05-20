package: giflib
version: "%(tag_basename)s"
tag: "6.1.3"
source: https://git.code.sf.net/p/giflib/code
build_requires:
  - GCC-Toolchain
  - alibuild-recipe-tools
prefer_system: (?!slc5)
prefer_system_check: |
  #!/bin/bash -e
  printf "#include <gif_lib.h>\n" | c++ -xc++ - -c -M 2>&1
---
#!/bin/bash -e
rsync -a --delete --exclude '**/.git' --delete-excluded $SOURCEDIR/ ./
make ${JOBS:+-j$JOBS}
make PREFIX=$INSTALLROOT install

# Modulefile
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
