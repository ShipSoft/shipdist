package: defaults-release
version: v1
env:
  CXXFLAGS: "-fPIC -g -O2 -std=c++17"
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELEASE"
  CMAKE_CXX_STANDARD: 17
disable:
  - AliEn-Runtime
  - MonALISA-gSOAP-client
  - AliEn-CAs
  - ApMon-CPP
  - DDS
overrides:
  autotools:
    tag: v1.6.3
  boost:
    version:  "%(tag_basename)s"
    tag: "v1.70.0"
    requires:
      - "GCC-Toolchain:(?!osx)"
      - Python
    prefer_system_check: |
     printf "#include \"boost/version.hpp\"\n# if (BOOST_VERSION < 106400)\n#error \"Cannot use system's boost. Boost > 1.64.00 required.\"\n#endif\nint main(){}" \
     | gcc -I$BOOST_ROOT/include -xc++ - -o /dev/null
  GCC-Toolchain:
    tag: v7.3.0-alice2
    prefer_system_check: |
      set -e
      which gfortran || { echo "gfortran missing"; exit 1; }
      which cc && test -f $(dirname $(which cc))/c++ && printf "#define GCCVER ((__GNUC__ << 16)+(__GNUC_MINOR__ << 8)+(__GNUC_PATCHLEVEL__))\n#if (GCCVER < 0x060000 || GCCVER > 0x100000)\n#error \"System's GCC cannot be used: we need GCC 6.X. We are going to compile our own version.\"\n#endif\n" | cc -xc++ - -c -o /dev/null
  ROOT:
    prefer_system_check: |
      VERSION=$(root-config --version)
      REQUESTED_VERSION=${REQUESTED_VERSION#v}
      REQUESTED_VERSION=${REQUESTED_VERSION//-/.}
      if [ $(printf "${VERSION}\n${REQUESTED_VERSION}" | sort -V | head -1) != "${VERSION}" ]; then
          echo "ROOT version $VERSION sufficient"
      else
          echo "ROOT version $VERSION insufficient"
          exit 1
      fi
      FEATURES="builtin_pcre mathmore xml ssl opengl http gdml pythia8 roofit soversion vdt xrootd"
      for FEATURE in $FEATURES; do
          root-config --has-$FEATURE | grep -q yes || { echo "$FEATURE missing"; exit 1; }
      done
  GSL:
    version: "v1.16%(defaults_upper)s"
    source: https://github.com/alisw/gsl
    tag: "release-1-16"
    prefer_system_check: |
      printf "#include \"gsl/gsl_version.h\"\n#define GSL_V GSL_MAJOR_VERSION * 100 + GSL_MINOR_VERSION\n# if (GSL_V < 116)\n#error \"Cannot use system's gsl. Notice we only support versions from 1.16 (included)\"\n#endif\nint main(){}"\
       | gcc  -I"$GSL_ROOT/include" -xc++ - -o /dev/null
  protobuf:
    version: "%(tag_basename)s"
    tag: "v3.12.3"
  CMake:
    version: "%(tag_basename)s"
    tag: "v3.18.2"
    prefer_system_check: |
      verge() { [[  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]]; }
      type cmake && verge 3.18.2 `cmake --version | sed -e 's/.* //' | cut -d. -f1,2,3`
  FairRoot:
    prefer_system_check: |
      ls $FAIRROOT_ROOT/ > /dev/null && \
      ls $FAIRROOT_ROOT/lib > /dev/null && \
      ls $FAIRROOT_ROOT/include > /dev/null && \
      grep v18.6.10 $FAIRROOT_ROOT/include/FairVersion.h
  FairMQ:
    version: "%(tag_basename)s"
    tag: "v1.4.38"
    prefer_system_check: |
      ls $FAIRMQ_ROOT/ > /dev/null && \
      ls $FAIRMQ_ROOT/lib > /dev/null && \
      ls $FAIRMQ_ROOT/include > /dev/null && \
  FairLogger:
    version: "%(tag_basename)s"
    tag: "v1.9.0"
    prefer_system_check: |
      ls $FAIRLOGGER_ROOT/ > /dev/null && \
      ls $FAIRLOGGER_ROOT/lib > /dev/null && \
      ls $FAIRLOGGER_ROOT/include/fairlogger > /dev/null && \
      grep 1.9.0 $FAIRLOGGER_ROOT/include/fairlogger/Version.h
  GEANT4:
    version: "%(tag_basename)s"
    tag: v10.7.3
    source: https://github.com/geant4/geant4.git
    prefer_system_check: |
      VERSION=$(geant4-config --version)
      REQUESTED_VERSION=${REQUESTED_VERSION#v}
      verlte() {
          printf '%s\n' "$1" "$2" | sort -C -V
      }
      verlt() {
          ! verlte "$2" "$1"
      }
      if ! verlt $VERSION $REQUESTED_VERSION; then
        echo "GEANT4 version $VERSION sufficient"
      else
        echo "GEANT4 version $VERSION insufficient"
        exit 1
      fi
    requires:
      - "GCC-Toolchain:(?!osx)"
      - opengl
      - XercesC
    env:
     G4INSTALL : $GEANT4_ROOT
     G4DATASEARCHOPT : "-mindepth 2 -maxdepth 4 -type d -wholename"
     G4ABLADATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4ABLA*'`"  ## v10.4.px only
     G4ENSDFSTATEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4ENSDFSTATE*'`"
     G4INCLDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4INCL*'`"  ## v10.5.px only
     G4LEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4EMLOW*'`"
     G4LEVELGAMMADATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*PhotonEvaporation*'`"
     G4NEUTRONHPDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4NDL*'`"
     G4NEUTRONXSDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4NEUTRONXS*'`"   ## v10.4.px only
     G4PARTICLEXSDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4PARTICLEXS*'`"   ## v10.5.px only
     G4PIIDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4PII*'`"
     G4RADIOACTIVEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*RadioactiveDecay*'`"
     G4REALSURFACEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*RealSurface*'`"
     G4SAIDXSDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT  '*data*G4SAIDDATA*'`"
  GEANT4_VMC:
    version: "%(tag_basename)s"
    tag: v5-4
    prefer_system_check: |
      ls $GEANT4_VMC_ROOT/bin > /dev/null && \
      ls $GEANT4_VMC_ROOT/lib/libg4root.so > /dev/null && \
      ls $GEANT4_VMC_ROOT/lib/libgeant4vmc.so> /dev/null && \
      ls $GEANT4_VMC_ROOT/lib/libmtroot.so > /dev/null && \
      ls $GEANT4_VMC_ROOT/include/g4root > /dev/null && \
      ls $GEANT4_VMC_ROOT/include/geant4vmc > /dev/null && \
      ls $GEANT4_VMC_ROOT/include/mtroot > /dev/null && \
      true
  VMC:
    version: "%(tag_basename)s"
    tag: v1-1-p1
    prefer_system_check: |
      ls $VMC_ROOT/include > /dev/null && \
      true
  GENIE:
    prefer_system_check: |
      ls $GENIE_ROOT/genie > /dev/null && \
      ls $GENIE_ROOT/genie/bin > /dev/null && \
      ls $GENIE_ROOT/genie/config > /dev/null && \
      ls $GENIE_ROOT/genie/data > /dev/null && \
      ls $GENIE_ROOT/genie/inc > /dev/null && \
      ls $GENIE_ROOT/genie/lib > /dev/null && \
      ls $GENIE_ROOT/genie/src > /dev/null && \
      true
  log4cpp:
    tag: 1b9f8f7c031d6947c7468d54bc1da4b2f414558d
    prefer_system_check: | 
      ls $LOG4CPP_ROOT/include/ > /dev/null && \
      ls $LOG4CPP_ROOT/lib/ > /dev/null && \
      true
  apfel:
    tag: 3.0.6
    prefer_system_check: |
      VERSION=$(apfel-config --version)
      verlte() {
          printf '%s\n' "$1" "$2" | sort -C -V
      }
      verlt() {
          ! verlte "$2" "$1"
      }
      if ! verlt $VERSION $REQUESTED_VERSION; then
        echo "apfel version $VERSION sufficient"
      else
        echo "apfel version $VERSION insufficient"
        exit 1
      fi
  pythia:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/pythia8
    tag: v8230-ship
    requires:
      - lhapdf
      - HepMC
      - boost
    prefer_system_check: |
      VERSION=$(pythia8-config --version)
      REQUESTED_VERSION=${REQUESTED_VERSION#v}
      VERSION=${VERSION//.}
      verlte() {
          printf '%s\n' "$1" "$2" | sort -C -V
      }
      verlt() {
          ! verlte "$2" "$1"
      }
      if ! verlt $VERSION $REQUESTED_VERSION; then
        echo "pythia8 version $VERSION sufficient"
      else
        echo "pythia8 version $VERSION insufficient"
        exit 1
      fi
      pythia8-config --with-lhapdf6 || { echo "lhapdf6 support missing."; exit 1; }
  vgm:
    version: "%(tag_basename)s"
    tag: "4.4"
  evtGen:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/evtgen
    tag: R01-06-00-ship
    prefer_system_check: |
      ls $EVTGEN_ROOT/include > /dev/null && \
      ls $EVTGEN_ROOT/lib > /dev/null && \
      ls $EVTGEN_ROOT/lib/libEvtGenExternal.so > /dev/null && \
      ls $EVTGEN_ROOT/lib/libEvtGen.so > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGen > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGenBase > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGenExternal > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGenModels > /dev/null
  PHOTOSPP:
    prefer_system_check: |
      ls $PHOTOSPP_ROOT/ > /dev/null && \
      ls $PHOTOSPP_ROOT/include/Photos > /dev/null && \
      ls $PHOTOSPP_ROOT/lib > /dev/null && \
      ls $PHOTOSPP_ROOT/lib/libPhotospp.a > /dev/null && \
      ls $PHOTOSPP_ROOT/lib/libPhotosppHEPEVT.so > /dev/null && \
      ls $PHOTOSPP_ROOT/lib/libPhotosppHepMC.so > /dev/null && \
      ls $PHOTOSPP_ROOT/lib/libPhotospp.so > /dev/null
  Tauolapp:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/Tauolapp
    tag: v1.1.5-ship
    prefer_system_check: |
      ls "$TAUOLAPP_ROOT"/lib > /dev/null && \
      ls "$TAUOLAPP_ROOT"/etc > /dev/null && \
      ls "$TAUOLAPP_ROOT"/include > /dev/null
  pythia6:
    version: "%(tag_basename)s"
    source: https://github.com/SND-LHC/pythia6
    tag: v6.4.28-snd
    prefer_system_check: |
      ls $PYTHIA6_ROOT/lib/libpythia6.so > /dev/null && \
      ls $PYTHIA6_ROOT/lib/libPythia6.so > /dev/null
  HepMC:
    prefer_system_check: |
      ls $HEPMC_ROOT/lib > /dev/null && \
      ls $HEPMC_ROOT/lib/libHepMC.so > /dev/null && \
      ls $HEPMC_ROOT/lib/libHepMC.so.4 > /dev/null && \
      ls $HEPMC_ROOT/lib/libHepMC.a > /dev/null && \
      ls $HEPMC_ROOT/lib/libHepMCfio.so > /dev/null && \
      ls $HEPMC_ROOT/lib/libHepMCfio.so.4 > /dev/null && \
      ls $HEPMC_ROOT/lib/libHepMCfio.a > /dev/null && \
      ls $HEPMC_ROOT/include > /dev/null && \
      ls $HEPMC_ROOT/include/HepMC > /dev/null && \
      ls $HEPMC_ROOT/include/HepMC/HepMCDefs.h > /dev/null && \
      grep "2.06" $HEPMC_ROOT/include/HepMC/HepMCDefs.h > /dev/null
  lhapdf:
    prefer_system_check: |
      VERSION=$(lhapdf-config --version)
      REQUESTED_VERSION=${REQUESTED_VERSION#lhapdf-}
      verlte() {
          printf '%s\n' "$1" "$2" | sort -C -V
      }
      verlt() {
          ! verlte "$2" "$1"
      }
      if ! verlt $VERSION $REQUESTED_VERSION; then
        echo "lhapdf version $VERSION sufficient"
      else
        echo "lhapdf version $VERSION insufficient"
        exit 1
      fi
  lhapdf5:
    prefer_system_check: |
      ls $LHAPDF5_ROOT/ > /dev/null && \
      ls $LHAPDF5_ROOT/bin > /dev/null && \
      ls $LHAPDF5_ROOT/include > /dev/null && \
      ls $LHAPDF5_ROOT/include/LHAPDF > /dev/null && \
      ls $LHAPDF5_ROOT/lib > /dev/null && \
      ls $LHAPDF5_ROOT/lib/libLHAPDF.so > /dev/null && \
      ls $LHAPDF5_ROOT/lib/libLHAPDF.so.0 > /dev/null && \
      ls $LHAPDF5_ROOT/lib/libLHAPDF.la > /dev/null && \
      ls $LHAPDF5_ROOT/lib/libLHAPDF.a > /dev/null && \
      ls $LHAPDF5_ROOT/lib64/python2.7/site-packages/lhapdf.py > /dev/null && \
      ls $LHAPDF5_ROOT/share/lhapdf > /dev/null 
  vgm:
    prefer_system_check: |
      ls $VGM_ROOT/ > /dev/null && \
      ls $VGM_ROOT/include > /dev/null && \
      ls $VGM_ROOT/include/BaseVGM > /dev/null && \
      ls $VGM_ROOT/include/ClhepVGM > /dev/null && \
      ls $VGM_ROOT/include/Geant4GM > /dev/null && \
      ls $VGM_ROOT/include/RootGM > /dev/null && \
      ls $VGM_ROOT/include/VGM > /dev/null && \
      ls $VGM_ROOT/include/XmlVGM > /dev/null && \
      ls $VGM_ROOT/lib > /dev/null && \
      ls $VGM_ROOT/lib/libBaseVGM.a > /dev/null && \
      ls $VGM_ROOT/lib/libClhepVGM.a > /dev/null && \
      ls $VGM_ROOT/lib/libGeant4GM.a > /dev/null && \
      ls $VGM_ROOT/lib/libRootGM.a > /dev/null && \
      ls $VGM_ROOT/lib/libXmlVGM.a > /dev/null
  XercesC:
    prefer_system_check: |
      VERSION=$(pkg-config xerces-c --modversion)
      REQUESTED_VERSION=${REQUESTED_VERSION#v}
      verlte() {
          printf '%s\n' "$1" "$2" | sort -C -V
      }
      verlt() {
          ! verlte "$2" "$1"
      }
      if ! verlt $VERSION $REQUESTED_VERSION; then
        echo "xerces-c version $VERSION sufficient"
      else
        echo "xerces-c version $VERSION insufficient"
        exit 1
      fi
  googletest:
    prefer_system_check: |
      VERSION=$(pkg-config gtest --modversion)
      REQUESTED_VERSION=${REQUESTED_VERSION#v}
      verlte() {
          printf '%s\n' "$1" "$2" | sort -C -V
      }
      verlt() {
          ! verlte "$2" "$1"
      }
      if ! verlt $VERSION $REQUESTED_VERSION; then
        echo "googletest version $VERSION sufficient"
      else
        echo "googletest version $VERSION insufficient"
        exit 1
      fi
---
# This file is included in any build recipe and it's only used to set
# environment variables. Which file to actually include can be defined by the
# "--defaults" option of alibuild.
