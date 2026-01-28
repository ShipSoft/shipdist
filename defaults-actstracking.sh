package: defaults-actstracking
version: v1
env:
  CXXFLAGS: "-fPIC -g -O2 -std=c++20"
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELEASE"
  CMAKE_CXX_STANDARD: "20"
overrides:
  boost:
    version: "%(tag_basename)s"
    tag: "v1.83.0"
    requires:
      - "GCC-Toolchain:(?!osx)"
      - Python
    prefer_system_check: |
     printf "#include \"boost/version.hpp\"\n# if (BOOST_VERSION < 107700)\n#error \"Cannot use system's boost. Boost > 1.77.00 required.\n#endif\nint main(){}" \
     | gcc -I$BOOST_ROOT/include -xc++ - -o /dev/null
  GCC-Toolchain:
    tag: v13.2.0-alice1
    prefer_system_check: |
      set -e
      which gfortran || { echo "gfortran missing"; exit 1; }
      which gcc && test -f $(dirname $(which gcc))/c++ && printf "#define GCCVER ((__GNUC__ * 10000)+(__GNUC_MINOR__ * 100)+(__GNUC_PATCHLEVEL__))\n#if (GCCVER < 130000)\n#error \"System's GCC cannot be used: we need at least GCC $REQUESTED_VERSION We are going to compile our own version.\"\n#endif\n" | gcc -xc++ - -c -o /dev/null
  FairShip:
    tag: master
    source: https://github.com/ShipSoft/FairShip
    requires:
      - generators
      - simulation
      - FairRoot
      - FairLogger
      - GENIE
      - GenFit
      - GEANT4
      - PHOTOSPP
      - EvtGen
      - ROOT
      - ROOTEGPythia6
      - VMC
      - HepMC3
      - acts
    build_requires:
      - FairCMakeModules
---
# This file is included in any build recipe and it's only used to set
# environment variables. Which file to actually include can be defined by the
# "--defaults" option of alibuild.
