package: Python-modules
version: "1.0"
requires:
  - Python
  - FreeType
  - libpng
build_requires:
  - curl
prepend_path:
  PYTHONPATH: $PYTHON_MODULES_ROOT/lib/python3.6/site-packages:$PYTHONPATH
prefer_system: (?!slc5)
prefer_system_check:
  python3 -c 'import matplotlib,numpy,scipy,certifi,IPython,ipywidgets,ipykernel,notebook.notebookapp,metakernel,yaml,sklearn,six,pymongo,mongoengine,pytest,pylint';
  if [ $? -ne 0 ]; then printf "Required Python modules are missing. You can install them with pip3:\n  pip3 install matplotlib numpy certifi ipython ipywidgets ipykernel notebook metakernel pyyaml pymongo mongoengine pytest pylint\n"; exit 1; fi
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
  - scipy
  - scikit-learn
  - six
  - mock
  - future
  - pymongo
  - mongoengine
  - pytest
  - pylint
  - alibuild
EoF
fi

# Force pip installation of packages found in current PYTHONPATH
unset PYTHONPATH

# The X.Y in pythonX.Y
export PYVER=$(python3 -c 'import distutils.sysconfig; print(distutils.sysconfig.get_python_version())')

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
         "scipy==1.2.2"         \
         "scikit-learn==0.19.1" \
         "matplotlib==2.2.4"    \
         "six"                  \
         "future"               \
         "pyyaml"               \
         "pymongo==3.10.1"      \
         "pytest==4.6.9"        \
         "pylint==1.9.5"        \
         "mongoengine==0.19.1"  \
         "alibuild"
do
  python3 -m pip install --user $X
done
unset PYTHONUSERBASE

# Test if matplotlib can be loaded
env PYTHONPATH="$INSTALLROOT/lib/python3.6/site-packages" python3 -c 'import matplotlib'

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
EoF
