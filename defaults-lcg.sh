package: defaults-lcg
version: v1
env:
  CXXFLAGS: "-fPIC -g -O2 -std=c++20"
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELEASE"
  CMAKE_CXX_STANDARD: "20"
  CMAKE_PREFIX_PATH: "/cvmfs/sft.cern.ch/lcg/views/LCG_109/x86_64-el9-gcc15-opt"
  XERCESC_ROOT: "/cvmfs/sft.cern.ch/lcg/views/LCG_109/x86_64-el9-gcc15-opt"
  EIGEN3_ROOT: "/cvmfs/sft.cern.ch/lcg/views/LCG_109/x86_64-el9-gcc15-opt"
  NLOHMANN_JSON_ROOT: "/cvmfs/sft.cern.ch/lcg/views/LCG_109/x86_64-el9-gcc15-opt"
  BOOST_ROOT: "/cvmfs/sft.cern.ch/lcg/views/LCG_109/x86_64-el9-gcc15-opt"
---
# Before running aliBuild with --defaults lcg, source the LCG environment:
#   source /cvmfs/sft.cern.ch/lcg/views/LCG_109/x86_64-el9-gcc15-opt/setup.sh
