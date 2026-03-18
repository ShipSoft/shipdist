package: uv
version: "0.7.12"
build_requires:
  - alibuild-recipe-tools
prefer_system_check: |
  command -v uv >/dev/null 2>&1 || exit 1
  SYSTEM_UV_VERSION=$(uv --version | awk '{print $2}')
  printf '%s\n%s\n' "$PKGVERSION" "$SYSTEM_UV_VERSION" | sort -V -C
---
#!/bin/bash -e
case $(uname -sm) in
  "Linux x86_64")  UV_PLATFORM="x86_64-unknown-linux-gnu" ;;
  "Linux aarch64") UV_PLATFORM="aarch64-unknown-linux-gnu" ;;
  "Darwin x86_64") UV_PLATFORM="x86_64-apple-darwin" ;;
  "Darwin arm64")  UV_PLATFORM="aarch64-apple-darwin" ;;
  *) echo "Unsupported platform: $(uname -sm)" >&2; exit 1 ;;
esac

mkdir -p "$INSTALLROOT/bin"
curl -LsSf "https://github.com/astral-sh/uv/releases/download/$PKGVERSION/uv-$UV_PLATFORM.tar.gz" \
  | tar -xzf - --strip-components=1 -C "$INSTALLROOT/bin" --wildcards '*/uv' '*/uvx'

"$INSTALLROOT/bin/uv" --version

mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --bin > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
