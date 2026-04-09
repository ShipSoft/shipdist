#!/bin/bash
set -e

# Source environment modules
source /etc/profile.d/modules.sh 2>/dev/null || true

# Load FairShip environment from CVMFS if available
if [ -d /cvmfs/ship.cern.ch ]; then
  eval "$(/cvmfs/ship.cern.ch/bin/alienv printenv FairShip/latest 2>/dev/null)" || true
fi

exec "$@"
