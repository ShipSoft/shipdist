package: defaults-fairship
version: v1
env:
  CXXFLAGS: "-fPIC -g -O2 -std=c++11"
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELWITHDEBINFO"
overrides:
  autotools:
    tag: v1.5.0
  OpenSSL:
    version:  "v1.0.2l"
    tag: v1.0.2l    
    prefer_system_check: |
      if [ `uname` = Darwin ]; then test -d `brew --prefix openssl || echo /dev/nope` || exit 1; fi; printf "#include <openssl/opensslv.h> \n#if (OPENSSL_VERSION_NUMBER > 0x10100000L)\n#error \"System's OpenSSL cannot be used: we need OpenSSL<1.1. We are going to compile our own version.\"\n#endif\n" | c++ -x c++ - -I`brew --prefix openssl`/include -c -o /dev/null || exit 1
  boost:
    version:  "%(tag_basename)s"
    tag: "v1.64.0-alice1"
    requires:
      - "GCC-Toolchain:(?!osx)"
      - Python
  GCC-Toolchain:
    tag: v6.2.0-alice1
    prefer_system_check: |
      set -e
      which gfortran || { echo "gfortran missing"; exit 1; }
      which cc && test -f $(dirname $(which cc))/c++ && printf "#define GCCVER ((__GNUC__ << 16)+(__GNUC_MINOR__ << 8)+(__GNUC_PATCHLEVEL__))\n#if (GCCVER < 0x060000 && GCCVER > 0x070000)\n#error \"System's GCC cannot be used: we need GCC 6.X. We are going to compile our own version.\"\n#endif\n" | cc -xc++ - -c -o /dev/null
  ROOT:
    tag: "v6-08-02"
    source: https://github.com/root-mirror/root
    requires:
      - AliEn-Runtime:(?!.*ppc64)
      - GSL
      - opengl:(?!osx)
      - Xdevel:(?!osx)
      - FreeType:(?!osx)
      - Python-modules
      - pythia
      - pythia6
  gSOAP:
    tag: "v2.8.45"
  GSL:
    prefer_system_check: |
      printf "#include \"gsl/gsl_version.h\"\n#define GSL_V GSL_MAJOR_VERSION * 100 + GSL_MINOR_VERSION\n# if (GSL_V < 116)\n#error \"Cannot use system's gsl. Notice we only support versions from 1.16 (included)\"\n#endif\nint main(){}" | gcc  -I$(brew --prefix gsl)/include -xc++ - -o /dev/null
  protobuf:
    version: "%(tag_basename)s"
    tag: "v3.0.2"
  CMake:
    version: "%(tag_basename)s"
    tag: "v3.8.2"
    prefer_system_check: |
      which cmake && case `cmake --version | sed -e 's/.* //' | cut -d. -f1,2,3 | head -n1` in [0-2]*|3.[0-7].*) exit 1 ;; esac
  FairRoot:
    source: https://github.com/PMunkes/FairRoot
    version: fairshipdevdev
    tag: fairshipdev
  GEANT4:
    version: "%(tag_basename)s"
    tag: fairshipdev
    source: https://github.com/PMunkes/geant4
    requires:
      - "GCC-Toolchain:(?!osx)"
      - opengl
      - XercesC
    env:
      G4INSTALL: "$GEANT4_ROOT"
      G4SYSTEM: "$(uname)-g++"
      G4VERSION: "Geant4-10.3.1"
      G4INSTALL_DATA: "$GEANT4_ROOT/share/Geant4-10.3.1/data"
      G4ABLADATA:               "$GEANT4_ROOT/share/Geant4-10.3.1/data/G4ABLA3.0"
      G4LEDATA:                 "$GEANT4_ROOT/share/Geant4-10.3.1/data/G4EMLOW6.50"
      G4ENSDFSTATEDATA:         "$GEANT4_ROOT/share/Geant4-10.3.1/data/G4ENSDFSTATE2.1"
      G4NeutronHPCrossSections: "$GEANT4_ROOT/share/Geant4-10.3.1/data/G4NDL4.5"
      G4NEUTRONHPDATA:          "$GEANT4_ROOT/share/Geant4-10.3.1/data/G4NDL4.5"
      G4NEUTRONXSDATA:          "$GEANT4_ROOT/share/Geant4-10.3.1/data/G4NEUTRONXS1.4"
      G4PIIDATA:                "$GEANT4_ROOT/share/Geant4-10.3.1/data/G4PII1.3"
      G4SAIDXSDATA:             "$GEANT4_ROOT/share/Geant4-10.3.1/data/G4SAIDDATA1.1"
      G4LEVELGAMMADATA:         "$GEANT4_ROOT/share/Geant4-10.3.1/data/PhotonEvaporation4.3.2"
      G4RADIOACTIVEDATA:        "$GEANT4_ROOT/share/Geant4-10.3.1/data/RadioactiveDecay5.1.1"
      G4REALSURFACEDATA:        "$GEANT4_ROOT/share/Geant4-10.3.1/data/RealSurface1.0"
  GEANT4_VMC:
    version: "%(tag_basename)s"
    tag: fairshipdev
    source: https://github.com/PMunkes/geant4_vmc
  G4PY:
    version: "%(tag_basename)s"
    tag: fairshipdev
    source: https://github.com/PMunkes/geant4
  lhapdf5:
    source: https://github.com/PMunkes/LHAPDF
    version: "%(tag_basename)s"
    tag: v5.9.1-ship1
    env:
      LHAPATH: "$LHAPDF_ROOT/share/LHAPDF"
      GEANT4_INSTALL: "$GEANT4_ROOT"
  pythia:
    version: "%(tag_basename)s%(defaults_upper)s"
    source: https://github.com/PMunkes/pythia8
    tag: master
    requires:
      - lhapdf5
      - HepMC
      - boost
  vgm:
    tag: "4.4"
  generators:
    requires:  
      - pythia6
      - pythia
      - PHOTOSPP
      - GENIE
      - EvtGen
  evtGen:
    tag: fairshipdev
  pythia6:
    source: https://github.com/PMunkes/pythia6
    tag: v6.4.28-ship1
  GEANT3:
    source: https://github.com/PMunkes/GEANT3
    tag: master  
---
# This file is included in any build recipe and it's only used to set
# environment variables. Which file to actually include can be defined by the
# "--defaults" option of alibuild.
