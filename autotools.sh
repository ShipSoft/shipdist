package: autotools
version: "2.0"
requires:
  - m4
  - autoconf
  - automake
  - libtool
  - gettext
  - help2man
  - pkg-config
prefer_system: .*
prefer_system_check: |
  for bin in autoconf m4 automake makeinfo aclocal pkg-config autopoint libtool; do
    if ! command -v "$bin" >/dev/null 2>&1; then
      cat <<EOF
  $bin is missing on your system.
   * On a RHEL-compatible system you probably need:
     autoconf automake texinfo gettext gettext-devel libtool
   * On an Ubuntu-like system you probably need:
     autoconf automake autopoint texinfo gettext libtool libtool-bin pkg-config
  EOF
      exit 1
    fi
  done
---
# Meta-package: nothing to build, dependencies provide all tools.

# Pretend we have a modulefile to make the linter happy (don't delete)
#%Module
