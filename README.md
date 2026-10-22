# shipdist

Recipes to build `FairShip` and its dependencies using `aliBuild`

## Overview

FairShip depends on a large software stack (ROOT, Geant4, Pythia, GENIE,
GenFit, FairRoot, ACTS, Python packages, ...). `shipdist` describes how to
build every piece of that stack, so that `aliBuild` can build it in the right
order with consistent versions.

* Each `<package>.sh` file is one **recipe**. The YAML header says which
  version to use (`tag`), where to get it (`source`) and what it depends on
  (`requires`, `build_requires`). The shell script below the `---` says how to
  compile and install it.
* `fairship.sh` is the top of the tree: building `FairShip` pulls in
  everything else.
* `defaults-*.sh` files hold settings shared by all recipes (compiler flags,
  C++ standard). They are selected with `--defaults`.
* Packages already provided by the system (`prefer_system` in a recipe) are
  not rebuilt.
* Versions are released with calendar versioning (e.g. `26.10`); see
  `CHANGELOG.md` for what changed in each release.

Most users do not need to build anything: ready-made builds are distributed
via CVMFS (see below). Building with `shipdist` is useful when CVMFS is not
available, or to test a different version of a package.

## General information

For general documentation, please refer to the `alisw/alibuild` documentation pages.

> [!NOTE]
> For most `aliBuild` commands (`aliBuild build`, `aliBuild init`, `aliDoctor`, `aliDeps`, ...) you have to specify the recipe directory with `-c shipdist` (or `-c $SHIPDIST`), as `aliBuild` will look for `alidist` otherwise.

### Quick start

```bash
# Get the recipes
git clone https://github.com/ShipSoft/shipdist.git

# Check that the system has what is needed (run from the parent directory)
aliDoctor FairShip -c shipdist --defaults release

# Build FairShip and all its dependencies
aliBuild build FairShip -c shipdist --defaults release

# List the built packages and enter an environment with FairShip loaded
alienv q
alienv enter FairShip/latest
```

To use a newer version of a package, change the `tag:` line in its recipe and
rebuild.

### Defaults

Defaults in use:

- `release`: Default for use with `FairShip/main`

The `fairship-2018` defaults for the `SHiP-2018` and `muflux` branches of
FairShip were removed in 2022. They are still available at the `SHiP-BDF-2020`
tag.

### Troubleshooting tips

#### `aliDoctor`

Checks which packages can be taken from the system and which will be built,
and reports missing system prerequisites before starting a long build:

```bash
aliDoctor FairShip -c shipdist --defaults release
```

#### `aliDeps`

Draws the dependency graph, useful to understand why a package is being built:

```bash
aliDeps FairShip -c shipdist --defaults release --outgraph deps.pdf
```

#### `aliBuild init` and local development packages

To work on FairShip (or any other package) itself, check out a local copy next
to `shipdist`. `aliBuild` then builds from that checkout instead of the tag in
the recipe:

```bash
aliBuild init FairShip -c shipdist --defaults release
# edit the code in ./FairShip, then
aliBuild build FairShip -c shipdist --defaults release
```

## CVMFS publishing (maintainers)

SHiP software is distributed through two CVMFS repositories, each with its own
publisher machine and service account. Changes to a repository are made inside
a transaction and become visible to users only once published.

| Repository | Publisher host | Service account |
|---|---|---|
| `ship-nightlies.cern.ch` | `cvmfs-ship-nightlies` | `cvship-nightlies` |
| `ship.cern.ch` | `cvmfs-ship.cern.ch` | `cvship` |

### Nightlies

```bash
ssh cvmfs-ship-nightlies
sudo -i -u cvship-nightlies
cvmfs_server transaction ship-nightlies.cern.ch
# ... install / update files under /cvmfs/ship-nightlies.cern.ch ...
cvmfs_server publish ship-nightlies.cern.ch
```

### Releases

```bash
ssh cvmfs-ship.cern.ch
sudo -i -u cvship
cvmfs_server transaction ship.cern.ch
# ... install / update files under /cvmfs/ship.cern.ch ...
cvmfs_server publish ship.cern.ch
```

If something goes wrong during a transaction, discard all changes with
`cvmfs_server abort <repository>` instead of publishing.

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
