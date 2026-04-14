#!/bin/bash
set -e

# Source environment modules
source /etc/profile.d/modules.sh 2>/dev/null || true

# Load FairShip environment from CVMFS if available
if [ -d /cvmfs/ship.cern.ch ]; then
  alienv_output=$(/cvmfs/ship.cern.ch/bin/alienv printenv FairShip/latest 2>&1)
  if ! eval "$alienv_output" 2>/dev/null; then
    echo "Warning: failed to load FairShip environment from CVMFS" >&2
    echo "$alienv_output" >&2
  fi
fi

exec "$@"
