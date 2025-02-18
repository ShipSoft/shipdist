# shipdist

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/ShipSoft/shipdist/main.svg)](https://results.pre-commit.ci/latest/github/ShipSoft/shipdist/main)

Recipes to build `FairShip` and it's dependencies using `aliBuild`

## General information

For general documentation, please refer to the `alisw/alibuild` documentation pages.

### Defaults

Defaults in use:

- `release`: Default for use with `FairShip/master`
- `fairship-2018`: Default for use with `FairShip/muflux` and legacy branches

### Troubleshooting tips

#### `aliDoctor`

#### `aliDeps`

#### `aliBuild init` and local development packages

## Platform specific information

Information for different platforms available below.

If you are working on a platform that is not listed below, `containers/toolbox` or `docker` can be used to conveniently set up a working environment with e.g. Fedora.

### With CVMFS

On platforms which can use CVMFS, most dependencies can be used from CVMFS and don't need to be built locally. Information to follow.

### CERN CentOS 7

See [ALICE documentation](https://alice-doc.github.io/alice-analysis-tutorial/building/prereq-centos7.html) for build pre-requisites.

No longer supported.

### RHEL 9

See [ALICE documentation](https://alice-doc.github.io/alice-analysis-tutorial/building/prereq-alma9.html) for build pre-requisites.

Officially supported as platform for lxplus9 and HTCondor, CVMFS builds available.

### Ubuntu 22.04

See [ALICE documentation](https://alice-doc.github.io/alice-analysis-tutorial/building/prereq-ubuntu.html) for build pre-requisites.

Officially supported with CVMFS builds available.

### macOS

Known to **NOT** work, but there is interest to make it work.

Please write to the `ship-software` egroup, if you are interested in helping.

### Other platforms

See [ALICE documentation](https://alice-doc.github.io/alice-analysis-tutorial/building/) for information useful for building.

Platforms known to work with some tweaking:

* Ubuntu
* Fedora
* Arch
