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
  ROOT:
    prefer_system_check: |
      root-config --version || exit 1
      if [[ "$REQUESTED_VERSION" == "master" || "$REQUESTED_VERSION" == "ship-master" ]]; then
          echo "Branch $REQUESTED_VERSION selected, skipping version check."
          exit 0
      fi
      VERSION=$(root-config --version)
      REQUESTED_VERSION=${REQUESTED_VERSION#v}
      REQUESTED_VERSION=${REQUESTED_VERSION//-/.}
      verlte() {
          printf '%s\n' "$1" "$2" | sort -C -V
      }
      verlt() {
          ! verlte "$2" "$1"
      }
      if ! verlt $VERSION $REQUESTED_VERSION; then
          echo "ROOT version $VERSION sufficient"
      else
          echo "ROOT version $VERSION insufficient ($REQUESTED_VERSION requested)"
          exit 1
      fi
      FEATURES="builtin_pcre mathmore xml ssl opengl http gdml pythia8 roofit soversion vdt xrootd"
      for FEATURE in $FEATURES; do
          root-config --has-$FEATURE | grep -q yes || { echo "$FEATURE missing"; exit 1; }
      done
  GSL:
    version: "v1.16%(defaults_upper)s"
    tag: "release-1-16"
    source: https://github.com/alisw/gsl
    prefer_system_check: |
      printf "#include \"gsl/gsl_version.h\"\n#define GSL_V GSL_MAJOR_VERSION * 100 + GSL_MINOR_VERSION\n# if (GSL_V < 116)\n#error \"Cannot use system's gsl. Notice we only support versions from 1.16 (included)\"\n#endif\nint main(){}"\
       | gcc  -I"$GSL_ROOT/include" -xc++ - -o /dev/null
  protobuf:
    version: "%(tag_basename)s"
    tag: "v3.12.3"
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
      - VMC
      - acts
      - HepMC3
  flatbuffers:
    version: v2.0.8
  GEANT4:
    version: "%(tag_basename)s"
    tag: v11.1.3
    source: https://github.com/geant4/geant4.git
    prefer_system_check: |
      ls $GEANT4_ROOT/bin > /dev/null && \
      ls $GEANT4_ROOT/bin/geant4-config > /dev/null && \
      ls $GEANT4_ROOT/bin/geant4.csh > /dev/null && \
      ls $GEANT4_ROOT/bin/geant4.sh > /dev/null && \
      ls $GEANT4_ROOT/include > /dev/null && \
      ls $GEANT4_ROOT/include/Geant4 > /dev/null && \
      ls $GEANT4_ROOT/lib/ > /dev/null && \
      true
    requires:
      - "GCC-Toolchain:(?!osx)"
      - opengl
      - XercesC
    env:
      G4INSTALL: $GEANT4_ROOT
      G4DATASEARCHOPT: "-mindepth 2 -maxdepth 4 -type d -wholename"
      G4ABLADATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4ABLA*'`"  ## v10.4.px only
      G4ENSDFSTATEDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4ENSDFSTATE*'`"
      G4INCLDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4INCL*'`"  ## v10.5.px only
      G4LEDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4EMLOW*'`"
      G4LEVELGAMMADATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*PhotonEvaporation*'`"
      G4NEUTRONHPDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4NDL*'`"
      G4NEUTRONXSDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4NEUTRONXS*'`"   ## v10.4.px only
      G4PARTICLEXSDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4PARTICLEXS*'`"   ## v10.5.px only
      G4PIIDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4PII*'`"
      G4RADIOACTIVEDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*RadioactiveDecay*'`"
      G4REALSURFACEDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*RealSurface*'`"
      G4SAIDXSDATA: "`find ${G4INSTALL} $G4DATASEARCHOPT  '*data*G4SAIDDATA*'`"
  GEANT4_VMC:
    version: "%(tag_basename)s"
    tag: v6-1-p1
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
    tag: v2-0
    prefer_system_check: |
      ls $VMC_ROOT/include > /dev/null && \
      true
  GEANT3:
    tag: v4-4
  pythia:
    version: "%(tag_basename)s"
    tag: 8311Fairship
    source: https://github.com/webbjm/pythia8
    requires:
      - lhapdf
      - HepMC
      - boost
    prefer_system_check: |
      ls $PYTHIA_ROOT/bin > /dev/null && \
      ls $PYTHIA_ROOT/bin/pythia8-config > /dev/null && \
      ls $PYTHIA_ROOT/include/ > /dev/null && \
      ls $PYTHIA_ROOT/include/Pythia8 > /dev/null && \
      ls $PYTHIA_ROOT/include/Pythia8Plugins > /dev/null && \
      ls $PYTHIA_ROOT/lib/libpythia8.a > /dev/null && \
      ls $PYTHIA_ROOT/lib/libpythia8lhapdf6.so > /dev/null && \
      ls $PYTHIA_ROOT/lib/libpythia8.so > /dev/null && \
      true
  vgm:
    tag: "v5-2"
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
  evtGen:
    version: "%(tag_basename)s"
    tag: "R02-02-00-alice2"
    source: https://github.com/alisw/EVTGEN
    prefer_system_check: |
      ls $EVTGEN_ROOT/include > /dev/null && \
      ls $EVTGEN_ROOT/lib > /dev/null && \
      ls $EVTGEN_ROOT/lib/libEvtGenExternal.so > /dev/null && \
      ls $EVTGEN_ROOT/lib/libEvtGen.so > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGen > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGenBase > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGenExternal > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGenModels > /dev/null
---
# This file is included in any build recipe and it's only used to set
# environment variables. Which file to actually include can be defined by the
# "--defaults" option of alibuild.
