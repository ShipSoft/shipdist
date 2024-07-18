# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to Calendar Versioning (year.month.day).

Until May 2022 (inclusive) no changelog was kept. We might try to reconstruct it in future.

## Unreleased

### Added

### Fixed

* Python-modules: Remove obsolete workaround for scikit-garden
  Installing numpy without specifying the version ahead of the other
  dependencies lead to the  installation of two conflicting numpy versions, one
  of which broke matplotlib.

### Changed

* XRootD: Update to 5.7.1
* FairRoot: Update to v18.6.10 (support C++20, stepping stone to v19)
* FairShip: Clean up recipe, remove unused gtest dependency

### Removed

## [24.09](https://github.com/ShipSoft/shipdist/tree/24.09)

### Fixed

* VMC, GEANT4-VMC: Fix ROOT/VDT discovery in CMake
* ROOT: defaults didn't pick up CVMFS version

### Changed

* XRootD: build with KRB5 support
* ROOT: Update to 6.28
* GENIE: Update to 3.4.2

### Removed

* GEANT3: remove as it is not used

## [24.07](https://github.com/ShipSoft/shipdist/tree/24.07)

### Changed

* XRootD: Update to 5.7.0 to fix authentication issue with EOS

## [24.06](https://github.com/ShipSoft/shipdist/tree/24.06)

Ubuntu 22.04 is now also supported.

### Fixed

* bz2: version number set to string (1.0 -> "1.0")

### Changed

* Geant4: Update to 10.7.3, as required for Ubuntu 22.04
* Python-modules-list: scikit-learn and sklearn-evaluation module version requirement relaxed from == to >=
* FairRoot: Update to 19.0.0

### Removed

* madgraph: remove as it is not used

## [24.05.1](https://github.com/ShipSoft/shipdist/tree/24.05.1)

### Changed

* ZeroMQ: Update to 4.3.5 and change to upstream repo (an up-to-date version is required by SWAN)

## [24.05](https://github.com/ShipSoft/shipdist/tree/24.05)

### Added

* Add python-system.sh recipe to determine whether system python is useable

### Fixed

* XRootD: Update to 5.6.9 to fix authentication issue with EOS

### Changed

* ROOT: Update to latest patch release in 6.26 series
* openssl: update from ALICE
* Housekeeping: Update README with information relevant to SHiP
* GEANT4: Update version to v11.2.1
* flatbuffers: Update recipe from ALICE
* BOOST: update recipe and version to 1.85

## [24.01](https://github.com/ShipSoft/shipdist/tree/24.01)

### Added

* Housekeeping: Keep track of changes in `CHANGELOG.md`

### Fixed

* Recipe: ZeroMQ system check not working
* PHOTOSPP: use gfortan (F77 used by mistake for GCC > 9)
* PHOTOSPP: fix prefer_system_check (so version)

### Changed

* Defaults: Move to `defaults-release`
* Recipe: Update FairShip recipe from sndsw recipe
* Recipe: Use ALICE method of installing python depencencies in virtual env
* ROOT: Update to latest bugfix release of 6.26 series: 6.26/14
* Recipe: Update uuid from ALICE recipe
* lhapdf: update recipe and version from snddist
* openssl: update from ALICE for new openssl versions in SLC9
* XRootD: update recipe from ALICE, don't overwrite version in defaults
* pythia6: use version from SND@LHC
* ofi: update version to v1.14.0
* PHOTOSPP: change source repo and update version and recipe
* PHOTOSPP: fix dependencies
* python-modules-list: add future
* Tauolapp: add prefer_system_check

### Removed

* Defaults: Remove defaults-fairship
* Recipe: Remove sndsw
* Housekeeping: Don't use `pull` to automatically pull changes from sndsw, remove pull.yml

## [SHiP-BDF-2020](https://github.com/ShipSoft/shipdist/commit/a3e02452a66000efb7ee1cc68c955113b3ca2e06)

Release used prior to ECN3 studies.
