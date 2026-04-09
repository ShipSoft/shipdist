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

## CI

### What's in place

- **Recipe linting** (`.github/workflows/recipe-checks.yml`): runs on every push/PR
- **Build workflow** (`.github/workflows/build.yml`): builds FairShip on self-hosted runners with S3 remote store caching
- **Container image** (`container/`): minimal AlmaLinux 9 image with CVMFS client, loads FairShip from `/cvmfs/ship.cern.ch`

### Setup required before first use

1. **S3 credentials**: add `S3_ACCESS_KEY_ID` and `S3_SECRET_ACCESS_KEY` as GitHub Actions secrets (for `s3.cern.ch/swift/v1/ship-packages`)
2. **Seed the remote store**: run a full build with `--remote-store https://s3.cern.ch/swift/v1/ship-packages::rw` to populate the cache
3. **Container registry**: authenticate the runner to push to `registry.cern.ch/ship/ship-sim`

### Remaining work

4. **CVMFS publishing**: set up `ship-cvmfs-builder-slc9` as a CVMFS Stratum-0 publisher for `ship.cern.ch`, then add a publish job to the workflow (following the LCG bits pattern: fetch tarballs from S3, unpack to CVMFS, `cvmfs_server transaction`/`publish`)
5. **unpacked.cern.ch**: submit `registry.cern.ch/ship/ship-sim` to the DUCC wishlist for CVMFS distribution of the container image
6. **Branch protection**: require the `build` check to pass before merging
7. **Failure notifications**: add alerting for scheduled build failures

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
