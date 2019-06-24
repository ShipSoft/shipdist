package: Python-modules
version: "1.0"
requires:
  - Python
  - FreeType
  - libpng
build_requires:
  - curl
env:
  SSL_CERT_FILE: "$(env PYTHONPATH=$PYTHON_MODULES_ROOT/lib/python$(python -c \"import distutils.sysconfig; print(distutils.sysconfig.get_python_version())\")/site-packages:$PYTHONPATH python -c \"import certifi; print certifi.where()\")"
prepend_path:
  PYTHONPATH: $PYTHON_MODULES_ROOT/lib/python2.7/site-packages:$PYTHONPATH
prefer_system: (?!slc5)
prefer_system_check:
  python -c 'import matplotlib,numpy, scipy, certifi,IPython,ipywidgets,ipykernel,notebook.notebookapp,metakernel,yaml,sklearn';
  if [ $? -ne 0 ]; then printf "Required Python modules are missing. You can install them with pip (better as root):\n  pip install matplotlib numpy certifi ipython ipywidgets ipykernel notebook metakernel pyyaml\n"; exit 1; fi
---
#!/bin/bash -ex

if [[ ! $PYTHON_VERSION ]]; then
  cat <<EoF
Building our own Python modules.
If you want to avoid this please install the following modules (pip recommended):

  - matplotlib
  - numpy
  - certifi
  - ipython
  - ipywidgets
  - ipykernel
  - notebook
  - metakernel
  - pyyaml
  - scikit-learn

EoF
fi

# Force pip installation of packages found in current PYTHONPATH
unset PYTHONPATH

# The X.Y in pythonX.Y
export PYVER=$(python -c 'import distutils.sysconfig; print(distutils.sysconfig.get_python_version())')

# Install as much as possible with pip. Packages are installed one by one as we
# are not sure that pip exits with nonzero in case one of the packages failed.
export PYTHONUSERBASE=$INSTALLROOT
for X in "pip==19.1.1"          \
         "mock==1.3.0"          \
         "numpy==1.16.4"        \
         "certifi==2019.6.16"   \
         "ipython==5.8.0"       \
         "ipywidgets==5.2.3"    \
         "ipykernel==4.10.0"    \
         "notebook==4.4.1"      \
         "metakernel==0.24.2"   \
         "scipy==1.3.0"         \
         "scikit-learn==0.21.1" \
         "pyyaml"
do
  python -m pip install --user $X
done
unset PYTHONUSERBASE

# Install matplotlib (quite tricky)
MATPLOTLIB_TAG="3.0.3"
if [[ $ARCHITECTURE != slc* ]]; then
  # Simply get it via pip in most cases
  env PYTHONUSERBASE=$INSTALLROOT pip install --user "matplotlib==$MATPLOTLIB_TAG"
else

  # We are on a RHEL-compatible OS. We compile it ourselves, and link it to our dependencies

  # Check if we can enable the Tk interface
  python -c 'import _tkinter' && MATPLOTLIB_TKAGG=True || MATPLOTLIB_TKAGG=False
  MATPLOTLIB_URL="https://github.com/matplotlib/matplotlib/archive/v${MATPLOTLIB_TAG}.tar.gz"  # note the "v"
  curl -SsL "$MATPLOTLIB_URL" | tar xzf -
  cd matplotlib-*
  cat > setup.cfg <<EOF
[directories]
basedirlist  = ${FREETYPE_ROOT:+$PWD/fake_freetype_root,$FREETYPE_ROOT,}${LIBPNG_ROOT:+$LIBPNG_ROOT,}${ZLIB_ROOT:+$ZLIB_ROOT,}/usr/X11R6,$(freetype-config --prefix),$(libpng-config --prefix)
[gui_support]
gtk = False
gtkagg = False
tkagg = $MATPLOTLIB_TKAGG
wxagg = False
macosx = False
EOF

  # matplotlib wants include files in <PackageRoot>/include, but this is not the case for FreeType
  if [[ $FREETYPE_ROOT ]]; then
    mkdir fake_freetype_root
    ln -nfs $FREETYPE_ROOT/include/freetype2 fake_freetype_root/include
  fi

  export PYTHONPATH="$INSTALLROOT/lib/python/site-packages"
    python setup.py build
    python setup.py install --prefix "$INSTALLROOT"
  unset PYTHONPATH
fi

# Test if matplotlib can be loaded
env PYTHONPATH="$INSTALLROOT/lib/python/site-packages" python -c 'import matplotlib'

# Remove unneeded stuff
rm -rvf $INSTALLROOT/share            \
        $INSTALLROOT/lib/python*/test
find $INSTALLROOT/lib/python*                                              \
     -mindepth 2 -maxdepth 2 -type d -and \( -name test -or -name tests \) \
     -exec rm -rvf '{}' \;

# Fix shebangs to point to the correct Python from the runtime environment
grep -IlRE '#!.*python' $INSTALLROOT/bin | \
  xargs -n1 perl -p -i -e 's|^#!.*/python|#!/usr/bin/env python|'

# Test whether we can load Python modules (this is not obvious as some of them
# do not indicate some of their dependencies and break at runtime).
PYTHONPATH=$INSTALLROOT/lib64/python$PYVER/site-packages:$INSTALLROOT/lib/python$PYVER/site-packages:$PYTHONPATH \
  python -c "import matplotlib,numpy,certifi,IPython,ipywidgets,ipykernel,notebook.notebookapp,metakernel,yaml"

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 ${PYTHON_VERSION:+Python/$PYTHON_VERSION-$PYTHON_REVISION} ${ALIEN_RUNTIME_VERSION:+AliEn-Runtime/$ALIEN_RUNTIME_VERSION-$ALIEN_RUNTIME_REVISION}
# Our environment
setenv PYTHON_MODULES_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH $::env(PYTHON_MODULES_ROOT)/bin
prepend-path LD_LIBRARY_PATH $::env(PYTHON_MODULES_ROOT)/lib64
prepend-path LD_LIBRARY_PATH $::env(PYTHON_MODULES_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH $::env(PYTHON_MODULES_ROOT)/lib64" && \
                                      echo "prepend-path DYLD_LIBRARY_PATH $::env(PYTHON_MODULES_ROOT)/lib")
prepend-path PYTHONPATH $::env(PYTHON_MODULES_ROOT)/lib/python$PYVER/site-packages
setenv SSL_CERT_FILE  [exec python -c "import certifi; print certifi.where()"]
EoF
