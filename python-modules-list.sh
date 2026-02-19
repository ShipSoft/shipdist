package: Python-modules-list
version: "1.0"
env:
  PIP_BASE_REQUIREMENTS: |
    pip>=25.3
    setuptools>=80.10.1
    wheel>=0.45.1
    distro>=1.9.0
  PIP_REQUIREMENTS: |
    requests>=2.32.5
    ipykernel>=7.1.0
    ipython>=9.9.0
    ipywidgets>=8.1.8
    metakernel>=0.30.4
    mock>=5.2.0
    notebook>=7.5.2
    scons>=4.10.1
    pre-commit>=4.5.1
  PIP312_REQUIREMENTS: |
    PyYAML>=6.0.3
    psutil>=7.2.1
    uproot>=5.6.9
    numpy>=2.4.1
    scipy>=1.17.0
    Cython>=3.2.4
    seaborn>=0.13.2
    scikit-learn>=1.8.0
    sklearn-evaluation>=0.12.2
    Keras>=3.13.1
    xgboost>=3.1.3
    dryable>=1.2.0
    responses>=0.25.8
    pandas>=3.0.0
    pybind11>=3.0.1
build_requires:
  - alibuild-recipe-tools
---
#!/bin/bash -e
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
