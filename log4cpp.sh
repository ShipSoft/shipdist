package: log4cpp
version: "%(tag_basename)s%(defaults_upper)s"
tag: REL_1_1_1_Nov_26_2013
source: https://github.com/PMunkes/log4cpp
build_requires:
  - autotools
---
#!/bin/bash -ex
cp -a $SOURCEDIR/* .
./autogen.sh
./configure          --prefix=$INSTALLROOT  \
		     --enable-shared \
		     --enable-static 
make ${JOBS+-j$JOBS}
make install



