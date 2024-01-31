#!/usr/bin/env bash

SOURCE=${BASH_SOURCE[0]}
SCRIPT_DIR="$(dirname "$SOURCE")"
cd "$SCRIPT_DIR" || { echo "Could not change to script directory"; exit 1; }

PROJECT_ROOT="$SCRIPT_DIR"/../../
source "${PROJECT_ROOT}"/.venv/bin/activate || { echo "ERROR: Failed to activate virtual environment for python"; exit 1; }

python "${PROJECT_ROOT}"/src/jukebox/components/volume/run_configure_audio.py $@
