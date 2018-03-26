package: defaults-fairship
version: v1
env:
  CXXFLAGS: "-fPIC -g -O2 -std=c++11"
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELWITHDEBINFO"
disable:
  - AliEn-Runtime
  - MonALISA-gSOAP-client
  - AliEn-CAs
  - ApMon-CPP
  - DDS
overrides:
  autotools:
    tag: v1.5.0
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
      which cc && test -f $(dirname $(which cc))/c++ && printf "#define GCCVER ((__GNUC__ << 16)+(__GNUC_MINOR__ << 8)+(__GNUC_PATCHLEVEL__))\n#if (GCCVER < 0x060000 || GCCVER > 0x080000)\n#error \"System's GCC cannot be used: we need GCC 6.X. We are going to compile our own version.\"\n#endif\n" | cc -xc++ - -c -o /dev/null
  XRootD:
    tag: v4.6.1
  ROOT:
    version: "%(tag_basename)s"
    tag: "v6-12-06-ship"
    source: https://github.com/ShipSoft/root
    requires:
      - GSL
      - opengl:(?!osx)
      - Xdevel:(?!osx)
      - FreeType:(?!osx)
      - Python-modules
      - zlib
      - libxml2
      - "OpenSSL:(?!osx)"
      - "osx-system-openssl:(osx.*)"
      - XRootD
      - pythia
      - pythia6
  GSL:
    version: "v1.16%(defaults_upper)s"
    source: https://github.com/alisw/gsl
    tag: "release-1-16"
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
    source: https://github.com/ShipSoft/FairRoot
    version: "%(tag_basename)s"
    tag: Oct17-ship
    incremental_recipe: |
      make -j$JOBS;make install; MODULEDIR="$INSTALLROOT/etc/modulefiles"
      MODULEFILE="$MODULEDIR/$PKGNAME"
      mkdir -p "$MODULEDIR"
      cd $SOURCEDIR
      FAIRROOT_HASH=$(git rev-parse HEAD)
      cd $BUILDDIR
      cat > "$MODULEFILE" <<EoF
      #%Module1.0
      proc ModulesHelp { } {
      global version
      puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
      }
      set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
      module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PK      GHASH@@"
      # Dependencies
      module load BASE/1.0                                                                            \\
            ${GEANT3_VERSION:+GEANT3/$GEANT3_VERSION-$GEANT3_REVISION}                          \\
            ${GEANT4_VMC_VERSION:+GEANT4_VMC/$GEANT4_VMC_VERSION-$GEANT4_VMC_REVISION}          \\
            ${PROTOBUF_VERSION:+protobuf/$PROTOBUF_VERSION-$PROTOBUF_REVISION}                  \\
            ${PYTHIA6_VERSION:+pythia6/$PYTHIA6_VERSION-$PYTHIA6_REVISION}                      \\
            ${PYTHIA_VERSION:+pythia/$PYTHIA_VERSION-$PYTHIA_REVISION}                          \\
            ${VGM_VERSION:+vgm/$VGM_VERSION-$VGM_REVISION}                                      \\
            ${BOOST_VERSION:+boost/$BOOST_VERSION-$BOOST_REVISION}                              \\
            ROOT/$ROOT_VERSION-$ROOT_REVISION                                                   \\
            ${ZEROMQ_VERSION:+ZeroMQ/$ZEROMQ_VERSION-$ZEROMQ_REVISION}                          \\
            ${NANOMSG_VERSION:+nanomsg/$NANOMSG_VERSION-$NANOMSG_REVISION}                      \\
            ${GCC_TOOLCHAIN_ROOT:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
      # Our environment
      setenv FAIRROOT_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
      setenv FAIRROOT_HASH $FAIRROOT_HASH
      setenv VMCWORKDIR \$::env(FAIRROOT_ROOT)/share/fairbase/examples
      setenv GEOMPATH \$::env(VMCWORKDIR)/common/geometry
      setenv CONFIG_DIR \$::env(VMCWORKDIR)/common/gconfig
      prepend-path PATH \$::env(FAIRROOT_ROOT)/bin
      prepend-path LD_LIBRARY_PATH \$::env(FAIRROOT_ROOT)/lib
      prepend-path ROOT_INCLUDE_PATH \$::env(FAIRROOT_ROOT)/include
      $([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH      \$::env(FAIRROOT_ROOT)/lib")
      EoF
  log4cpp:
    version: "%(tag_basename)s"
    tag: REL_1_1_1_Nov_26_2013
    source: https://github.com/ShipSoft/log4cpp
  GEANT4:
    version: "%(tag_basename)s"
    tag: v10.3.2
    source: https://github.com/geant4/geant4.git
    requires:
      - "GCC-Toolchain:(?!osx)"
      - opengl
      - XercesC
    env:
      G4INSTALL: "$GEANT4_ROOT"
      G4SYSTEM: "$(uname)-g++"
      G4VERSION: "Geant4-10.3.2"
      G4INSTALL_DATA: "$GEANT4_ROOT/share/$G4VERSION/data"
      G4ABLADATA:               "$GEANT4_ROOT/share/$G4VERSION/data/G4ABLA3.0"
      G4LEDATA:                 "$GEANT4_ROOT/share/$G4VERSION/data/G4EMLOW6.50"
      G4ENSDFSTATEDATA:         "$GEANT4_ROOT/share/$G4VERSION/data/G4ENSDFSTATE2.1"
      G4NeutronHPCrossSections: "$GEANT4_ROOT/share/$G4VERSION/data/G4NDL4.5"
      G4NEUTRONHPDATA:          "$GEANT4_ROOT/share/$G4VERSION/data/G4NDL4.5"
      G4NEUTRONXSDATA:          "$GEANT4_ROOT/share/$G4VERSION/data/G4NEUTRONXS1.4"
      G4PIIDATA:                "$GEANT4_ROOT/share/$G4VERSION/data/G4PII1.3"
      G4SAIDXSDATA:             "$GEANT4_ROOT/share/$G4VERSION/data/G4SAIDDATA1.1"
      G4LEVELGAMMADATA:         "$GEANT4_ROOT/share/$G4VERSION/data/PhotonEvaporation4.3.2"
      G4RADIOACTIVEDATA:        "$GEANT4_ROOT/share/$G4VERSION/data/RadioactiveDecay5.1.1"
      G4REALSURFACEDATA:        "$GEANT4_ROOT/share/$G4VERSION/data/RealSurface1.0"
  GEANT4_VMC:
    version: "%(tag_basename)s"
    tag: v3-6-ship
    source: https://github.com/ShipSoft/geant4_vmc.git
  lhapdf5:
    source: https://github.com/ShipSoft/LHAPDF
    version: "%(tag_basename)s"
    tag: v5.9.1-ship1
    env:
      LHAPATH: "$LHAPDF_ROOT/share/LHAPDF"
      GEANT4_INSTALL: "$GEANT4_ROOT"
  GENIE:
    tag: v2.12.6-ship
  pythia:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/pythia8
    tag: v8230-ship
    requires:
      - lhapdf5
      - HepMC
      - boost
  vgm:
    version: "%(tag_basename)s"
    tag: "4.4"
  evtGen:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/evtgen
    tag: R01-06-00-ship
  PHOTOSPP:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/PHOTOSPP
    tag: v3.61
  Tauolapp:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/Tauolapp
    tag: v1.1.5-ship
  pythia6:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/pythia6
    tag: v6.4.28-ship1
  GEANT3:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/geant3
    tag: v3.2.1-ship
  madgraph5:
    version: "%(tag_basename)s"
    tag: v2.6.1-ship
---
# This file is included in any build recipe and it's only used to set
# environment variables. Which file to actually include can be defined by the
# "--defaults" option of alibuild.
