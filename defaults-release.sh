package: defaults-release
version: v1
env:
  CXXFLAGS: "-fPIC -g -O2 -std=c++17"
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELEASE"
  CMAKE_CXX_STANDARD: "17"
overrides:
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
    source: https://github.com/alisw/gsl
    tag: "release-1-16"
    prefer_system_check: |
      printf "#include \"gsl/gsl_version.h\"\n#define GSL_V GSL_MAJOR_VERSION * 100 + GSL_MINOR_VERSION\n# if (GSL_V < 116)\n#error \"Cannot use system's gsl. Notice we only support versions from 1.16 (included)\"\n#endif\nint main(){}"\
       | gcc  -I"$GSL_ROOT/include" -xc++ - -o /dev/null
  protobuf:
    version: "%(tag_basename)s"
    tag: "v3.12.3"
  GEANT4:
    version: "%(tag_basename)s"
    tag: v10.7.3
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
  pythia:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/pythia8
    tag: v8230-ship
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
    prefer_system_check: |
      ls $EVTGEN_ROOT/include > /dev/null && \
      ls $EVTGEN_ROOT/lib > /dev/null && \
      ls $EVTGEN_ROOT/lib/libEvtGenExternal.so > /dev/null && \
      ls $EVTGEN_ROOT/lib/libEvtGen.so > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGen > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGenBase > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGenExternal > /dev/null && \
      ls $EVTGEN_ROOT/include/EvtGenModels > /dev/null
  GEANT3:
    version: "%(tag_basename)s"
    source: https://github.com/vmc-project/geant3
    tag: v3-9
    prefer_system_check: |
      ls $GEANT3_ROOT/ > /dev/null && \
      ls $GEANT3_ROOT/include > /dev/null && \
      ls $GEANT3_ROOT/include/TGeant3 > /dev/null && \
      ls $GEANT3_ROOT/include/TGeant3/TGeant3.h > /dev/null && \
      ls $GEANT3_ROOT/lib64/libgeant321.so > /dev/null && \
      true
---
# This file is included in any build recipe and it's only used to set
# environment variables. Which file to actually include can be defined by the
# "--defaults" option of alibuild.
