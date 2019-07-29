package: defaults-fairship
version: v1
env:
  CXXFLAGS: "-fPIC -g -O2 -std=c++11"
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELEASE"
disable:
  - AliEn-Runtime
  - MonALISA-gSOAP-client
  - AliEn-CAs
  - ApMon-CPP
  - DDS
overrides:
  FairShip:
    tag: "SHiP-2018"
  autotools:
    tag: v1.5.0
  boost:
    version:  "%(tag_basename)s"
    tag: "v1.64.0-alice1"
    requires:
      - "GCC-Toolchain:(?!osx)"
      - Python
    prefer_system_check: |
     printf "#include \"boost/version.hpp\"\n# if (BOOST_VERSION < 106400)\n#error \"Cannot use system's boost. Boost > 1.64.00 required.\"\n#endif\nint main(){}" \
     | gcc -I$BOOST_ROOT/include -xc++ - -o /dev/null
  GCC-Toolchain:
    tag: v6.2.0-alice1
    prefer_system_check: |
      set -e
      which gfortran || { echo "gfortran missing"; exit 1; }
      which cc && test -f $(dirname $(which cc))/c++ && printf "#define GCCVER ((__GNUC__ << 16)+(__GNUC_MINOR__ << 8)+(__GNUC_PATCHLEVEL__))\n#if (GCCVER < 0x060000 || GCCVER > 0x090000)\n#error \"System's GCC cannot be used: we need GCC 6.X. We are going to compile our own version.\"\n#endif\n" | cc -xc++ - -c -o /dev/null
  XRootD:
    tag: v4.8.3
  ROOT:
    version: "%(tag_basename)s"
    tag: "v6-14-00-ship"
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
    build_requires:
      - CMake
      - "Xcode:(osx.*)"
      - libxml2
    prefer_system_check: |
      ls $ROOT_ROOT/aclocal > /dev/null && \
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
      ls $ROOT_ROOT/tmva > /dev/null && \
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
    tag: "v3.0.2"
  CMake:
    version: "%(tag_basename)s"
    tag: "v3.9.4"
    prefer_system_check: |
      which cmake && case `cmake --version | sed -e 's/.* //' | cut -d. -f1,2,3 | head -n1` in [0-2]*|3.[0-7].*) exit 1 ;; esac
  FairRoot:
    source: https://github.com/ShipSoft/FairRoot
    version: "%(tag_basename)s"
    tag: May30-ship
    prefer_system_check: |
      ls $FAIRROOT_ROOT/ > /dev/null && \
      ls $FAIRROOT_ROOT/lib > /dev/null && \
      ls $FAIRROOT_ROOT/include > /dev/null && \
      grep v-14.03 $FAIRROOT_ROOT/include/FairVersion.h
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
    prefer_system_check: |
      ls $GEANT4_VMC_ROOT/bin > /dev/null && \
      ls $GEANT4_VMC_ROOT/lib/libg4root.so > /dev/null && \
      ls $GEANT4_VMC_ROOT/lib/libgeant4vmc.so> /dev/null && \
      ls $GEANT4_VMC_ROOT/lib/libmtroot.so > /dev/null && \
      ls $GEANT4_VMC_ROOT/include/g4root > /dev/null && \
      ls $GEANT4_VMC_ROOT/include/geant4vmc > /dev/null && \
      ls $GEANT4_VMC_ROOT/include/mtroot > /dev/null && \
      true
  GENIE:
    tag: v2.12.6-ship
    prefer_system_check: |
      ls $GENIE_ROOT/genie > /dev/null && \
      ls $GENIE_ROOT/genie/bin > /dev/null && \
      ls $GENIE_ROOT/genie/config > /dev/null && \
      ls $GENIE_ROOT/genie/data > /dev/null && \
      ls $GENIE_ROOT/genie/inc > /dev/null && \
      ls $GENIE_ROOT/genie/lib > /dev/null && \
      ls $GENIE_ROOT/genie/src > /dev/null && \
      true
  pythia:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/pythia8
    tag: v8230-ship
    requires:
      - lhapdf5
      - HepMC
      - boost
    prefer_system_check: |
      ls $PYTHIA_ROOT/bin > /dev/null && \
      ls $PYTHIA_ROOT/bin/pythia8-config > /dev/null && \
      ls $PYTHIA_ROOT/include/ > /dev/null && \
      ls $PYTHIA_ROOT/include/Pythia8 > /dev/null && \
      ls $PYTHIA_ROOT/include/Pythia8Plugins > /dev/null && \
      ls $PYTHIA_ROOT/lib/libpythia8.a > /dev/null && \
      ls $PYTHIA_ROOT/lib/libpythia8lhapdf5.so > /dev/null && \
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
  GEANT3:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/geant3
    tag: v3.2.1-ship-patch-TVMC
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
