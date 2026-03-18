package: python-awkward-cpp
# awkward-cpp uses integer PyPI versions and is released from the awkward
# monorepo, so there are no standalone GitHub tags to track.
version: "52"
requires:
  - "Python:(slc|ubuntu)"
  - "Python-system:(?!slc.*|ubuntu)"
  - python-numpy
build_requires:
  - uv
  - alibuild-recipe-tools
prefer_system_check: |
  python3 -c 'import awkward_cpp; print(awkward_cpp.__version__)' || exit 1
  SYSTEM_VERSION=$(python3 -c 'import awkward_cpp; print(awkward_cpp.__version__)')
  printf '%s\n%s\n' "$PKGVERSION" "$SYSTEM_VERSION" | sort -V -C
prepend_path:
  PYTHONPATH: "$PYTHON_AWKWARD_CPP_ROOT/lib/python/site-packages"
---
#!/bin/bash -e
pyver=$(python3 -c 'import sysconfig; print(sysconfig.get_python_version())')
TARGET="$INSTALLROOT/lib/python$pyver/site-packages"
mkdir -p "$TARGET"

uv pip install --no-deps --no-cache-dir --target="$TARGET" --python="$(command -v python3)" "awkward-cpp==$PKGVERSION"

ln -snf "python$pyver" "$INSTALLROOT/lib/python"

mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
cat >> "$INSTALLROOT/etc/modulefiles/$PKGNAME" <<EOF
set PKG_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PYTHONPATH \$PKG_ROOT/lib/python/site-packages
EOF
