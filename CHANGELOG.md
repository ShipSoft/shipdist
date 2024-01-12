# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to Calendar Versioning (year.month.day).

Until May 2022 (inclusive) no changelog was kept. We might try to reconstruct it in future.

## Unreleased

### Added

* Housekeeping: Keep track of changes in `CHANGELOG.md`

### Fixed

* Recipe: ZeroMQ system check not working
* PHOTOSPP: use gfortan (F77 used by mistake for GCC > 9)

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

### Removed

* Defaults: Remove defaults-fairship
* Recipe: Remove sndsw
* Housekeeping: Don't use `pull` to automatically pull changes from sndsw, remove pull.yml

## [SHiP-BDF-2020](https://github.com/ShipSoft/shipdist/commit/a3e02452a66000efb7ee1cc68c955113b3ca2e06)

Release used prior to ECN3 studies.
