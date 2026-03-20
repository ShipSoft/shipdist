package: bitsorg
version: "%(tag_basename)s"
tag: "v0.1.1"
source: https://github.com/bitsorg/bits
requires:
  - "Python:(slc|ubuntu)"
  - "Python-system:(?!slc.*|ubuntu)"
  - python-pyyaml
  - python-requests
  - python-distro
  - python-jinja2
  # boto3 is not included; remote store support is unavailable.
build_requires:
  - uv
  - alibuild-recipe-tools
prefer_system_check: |
  python3 -c 'import alibuild_helpers' || exit 1
prepend_path:
  PYTHONPATH: "$BITSORG_ROOT/lib/python/site-packages"
  PATH: "$BITSORG_ROOT/bin"
---
#!/bin/bash -e
pyver=$(python3 -c 'import sysconfig; print(sysconfig.get_python_version())')
TARGET="$INSTALLROOT/lib/python$pyver/site-packages"
mkdir -p "$TARGET"

uv pip install --no-deps --no-cache-dir --target="$TARGET" --python="$(command -v python3)" "bitsorg==$PKGVERSION"

ln -snf "python$pyver" "$INSTALLROOT/lib/python"

# Move scripts installed into the target to the bin directory
mkdir -p "$INSTALLROOT/bin"
mv "$TARGET/../../../bin"/* "$INSTALLROOT/bin/"

mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EOF
set PKG_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PYTHONPATH \$PKG_ROOT/lib/python/site-packages
prepend-path PATH \$PKG_ROOT/bin
EOF
