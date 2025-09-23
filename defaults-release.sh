package: defaults-release
version: v1
env:
  CXXFLAGS: "-fPIC -g -O2 -std=c++17"
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELEASE"
  CMAKE_CXX_STANDARD: "17"
---
# This file is included in any build recipe and it's only used to set
# environment variables. Which file to actually include can be defined by the
# "--defaults" option of alibuild.
