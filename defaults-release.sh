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
  XRootD:
    tag: v5.3.1
  ROOT:
    tag: "v6-26-00"
    source: https://github.com/root-project/root
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
    build_requires:
      - CMake
      - "Xcode:(osx.*)"
      - libxml2
    prefer_system_check: |
      ls $ROOT_ROOT/bin > /dev/null && \
      ls $ROOT_ROOT/cmake > /dev/null && \
      ls $ROOT_ROOT/config > /dev/null && \
      ls $ROOT_ROOT/emacs > /dev/null && \
      ls $ROOT_ROOT/etc > /dev/null && \
      ls $ROOT_ROOT/fonts > /dev/null && \
      ls $ROOT_ROOT/geom > /dev/null && \
      ls $ROOT_ROOT/icons > /dev/null && \
      ls $ROOT_ROOT/include > /dev/null && \
      ls $ROOT_ROOT/lib > /dev/null && \
      ls $ROOT_ROOT/macros > /dev/null && \
      ls $ROOT_ROOT/man > /dev/null && \
      true
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
    version: "%(tag_basename)s"
    tag: "v18.4.2_snd"
    prefer_system_check: |
      ls $FAIRROOT_ROOT/ > /dev/null && \
      ls $FAIRROOT_ROOT/lib > /dev/null && \
      ls $FAIRROOT_ROOT/include > /dev/null && \
      grep v18.4.2 $FAIRROOT_ROOT/include/FairVersion.h
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
    tag: v10.7.2
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
  GENIE:
    tag: R-3_02_00
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
      ls $APFEL_ROOT/bin > /dev/null && \
      ls $APFEL_ROOT/lib > /dev/null && \
      ls $APFEL_ROOT/include > /dev/null && \
      true
  alpaca:
    version: v1.1
    prefer_system_check: |
      ls $ALPACA/bin > /dev/null && \
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
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/PHOTOSPP
    tag: v3.61
    prefer_system_check: |
      ls $PHOTOSPP_ROOT/ > /dev/null && \
      ls $PHOTOSPP_ROOT/include/Photos > /dev/null && \
      ls $PHOTOSPP_ROOT/lib > /dev/null && \
      ls $PHOTOSPP_ROOT/lib/libPhotospp.a > /dev/null && \
      ls $PHOTOSPP_ROOT/lib/libPhotosppHEPEVT.so > /dev/null && \
      ls $PHOTOSPP_ROOT/lib/libPhotosppHepMC.so.1.0.0 > /dev/null && \
      ls $PHOTOSPP_ROOT/lib/libPhotospp.so > /dev/null && \
      true
  Tauolapp:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/Tauolapp
    tag: v1.1.5-ship
  pythia6:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/pythia6
    tag: v6.4.28-ship1
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
      ls $LHAPDF_ROOT/ > /dev/null && \
      ls $LHAPDF_ROOT/bin > /dev/null && \
      ls $LHAPDF_ROOT/include > /dev/null && \
      ls $LHAPDF_ROOT/include/LHAPDF > /dev/null && \
      ls $LHAPDF_ROOT/lib > /dev/null && \
      ls $LHAPDF_ROOT/share/LHAPDF > /dev/null
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
      ls $XERCESC_ROOT/ > /dev/null && \
      ls $XERCESC_ROOT/bin > /dev/null && \
      ls $XERCESC_ROOT/include > /dev/null && \
      ls $XERCESC_ROOT/include/xercesc/ > /dev/null && \
      ls $XERCESC_ROOT/lib > /dev/null && \
      ls $XERCESC_ROOT/lib/libxerces-c-3.1.so > /dev/null && \
      ls $XERCESC_ROOT/lib/libxerces-c.a > /dev/null && \
      ls $XERCESC_ROOT/lib/libxerces-c.la > /dev/null && \
      ls $XERCESC_ROOT/lib/libxerces-c.so > /dev/null
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
  googletest:
    prefer_system_check: |
      ls $GOOGLETEST_ROOT/ > /dev/null && \
      ls $GOOGLETEST_ROOT/include > /dev/null && \
      ls $GOOGLETEST_ROOT/include/gmock > /dev/null && \
      ls $GOOGLETEST_ROOT/include/gtest > /dev/null && \
      ls $GOOGLETEST_ROOT/lib/libgmock.a > /dev/null && \
      ls $GOOGLETEST_ROOT/lib/libgmock_main.a > /dev/null && \
      ls $GOOGLETEST_ROOT/lib/libgtest.a > /dev/null && \
      ls $GOOGLETEST_ROOT/lib/libgtest_main.a > /dev/null && \
      true
---
# This file is included in any build recipe and it's only used to set
# environment variables. Which file to actually include can be defined by the
# "--defaults" option of alibuild.
