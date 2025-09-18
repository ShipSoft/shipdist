# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to Calendar Versioning (year.month.day).

Until May 2022 (inclusive) no changelog was kept. We might try to reconstruct it in future.

## Unreleased

### Added

* ACTS: Standalone recipe for new tracking framework
* HEPMC3: Recipe, required dependency for ACTS
* EIGEN3: Recipe, required dependency for ACTS
* Rust: Recipe to depend on system Rust toolchain
* npdb-client: Recipe to download and build client libraries.
* Defaults: defaults-actstracking, C++20 build environment to enable ACTS and its dependencies.
  Additional overrides setup to enable C++20 build compatibility, Fairship: added acts and hepmc3 as requirements,
  GEANT4: v10.7.3 -> v11.1.3, GEANT4VMC: v5-4 -> v6-1-p1, VMC: v1-1-p1 -> v2-0, pythia: v8230-ship -> v8311, GEANT3: v3-9 -> v4-4
  vgm: v5-2, evtGen: R01-06-00-ship -> R02-02-00-alice2, boost: 1.75.0 -> 1.83.0, gcc: 11.5.0 -> 13.2.0,
  flatbuffers: v1.11.0 -> v2.0.8
* TBB: Add recipe and dependency for ROOT

### Fixed

* ROOT: Disabled davix to resolve build issues
* FairRoot: Add missing GEANT3 dependency
* EvtGen: Fix detection of C++11
* ACTS/Eigen3/Hepmc3: Fixed module detection
* FairShip: Find python paths correctly

### Changed

* Defaults: Moved all overrides from defaults files to individual recipes to reduce duplication
  - defaults-release.sh: Moved all 12 package overrides to their respective recipe files, leaving only environment configuration
  - boost: Updated recipe from v1.75.0 to v1.70.0 and moved version, tag, requires, and prefer_system_check to recipe
  - GCC-Toolchain: Updated prefer_system_check in recipe to match defaults version
  - ROOT: Added prefer_system_check configuration to recipe
  - GSL: Updated prefer_system_check in recipe to match defaults version
  - protobuf: Updated recipe from v2.6.1 to v3.12.3 and added version/tag configuration
  - GEANT4: Updated recipe source, version, tag, requires, env, and prefer_system_check to match defaults
  - GEANT4_VMC, VMC: Added prefer_system_check configurations to recipes
  - pythia: Updated recipe source, tag, requires, and prefer_system_check to match defaults
  - vgm, evtGen, GEANT3: Added prefer_system_check configurations to recipes
  - FairRoot, FairMQ, FairLogger, GENIE, log4cpp, apfel, PHOTOSPP, Tauolapp, pythia6, HepMC, lhapdf, lhapdf5, XercesC, googletest: moved prefer_system_check configurations to respective recipe files
  - FairMQ: Updated recipe version from v1.4.49 to v1.4.38 to match defaults
  - Tauolapp: Updated recipe version format and tag from v1.1.5 to v1.1.5-ship to match defaults
  - pythia6: Updated recipe tag from 428-alice1 to v6.4.28-snd and source from alisw/pythia6.git to SND-LHC/pythia6 to match defaults
* Python-modules-list: Updated pip to v25.0.1
* Python-modules-list: Added pybind11 v2.13.6
* EvtGen: Added cmake build instructions required for R02-02-00
* Fairship: Added build option to include acts (if found)
* Fairship: Added acts and hepmc3 as dependency modules
* gcc-toolchain: Disabled gprofng in binutil config
* gcc-toolchain: Rebuild mpfr, gmp to be used with gdb
* FairLogger: Update to 2.3.0
* alibuild-recipe-tools: Update to 0.2.5
* googletest: Update to 1.17.0
* fmt: Update to 11.2.0
* lhapdf: Switch to upstream, update to 6.5.5
* Xerces-C: Update to 3.3.0
* flatbuffers: Update to 25.2.10
* XRootD: Update to 5.8.4
* autotools: Update to 1.6.4
* CMake: Update to 3.26.5 (match SLC9)
* boost: Update to 1.75.0 (match SLC9 version)
* GCC: Update to v11.2.0 when not using system toolchain
* Freetype: Update to 2.10, update recipe from alidist

## [25.08](https://github.com/ShipSoft/shipdist/tree/25.08)

Maintenance release with several fixes and no major version upgrades.

### Added

* Readd support for GEANT3, to allow using upstream FairRoot

### Fixed

* Freetype & XDevel: Fix freetype detection
* Fix various issues identified by alidistlint
* FairShip: set environment correctly

### Changed

* ROOT: Update recipe and version to 6.30.8
* vgm: update to v4-9 to support C++17
* ROOT: Explicitly enable PROOF for newer ROOT versions
* Root: Check version, features
* FairRoot: Update to 18.8.2

### Removed

* Alpaca: Unused, unmaintained and doesn't include all relevant production
  mechanisms for our use
* Remove unused recipes

## [24.10](https://github.com/ShipSoft/shipdist/tree/24.10)

### Added

* GenFit: Standalone recipe, use for FairShip

### Fixed

* Python-modules: Remove obsolete workaround for scikit-garden
  Installing numpy without specifying the version ahead of the other
  dependencies lead to the  installation of two conflicting numpy versions, one
  of which broke matplotlib.

### Changed

* XRootD: Update to 5.7.1
* FairRoot: Update to v18.6.10 (support C++20, stepping stone to v19)
* FairShip: Clean up recipe, remove unused gtest dependency

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
