#!/usr/bin/env bash
set -euo pipefail
SETUP_ONLY=0
if [[ ${1:-} == --setup-only ]]; then
  SETUP_ONLY=1
  shift
fi
source $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/common.sh
ensure_cache_layout
ensure_conda
ensure_dover_env
if [[ ${SETUP_ONLY} -eq 1 ]]; then
  echo t2av-dover ready
  exit 0
fi
INPUT_DIR=$(resolve_path ${1:-input})
OUTPUT_DIR=$(resolve_path ${2:-Output})
require_dir ${INPUT_DIR}
require_video_files ${INPUT_DIR}
mkdir -p ${OUTPUT_DIR}
conda_run_in t2av-dover python ${CODE_ROOT}/scripts/batch_dover.py --input ${INPUT_DIR} --output ${OUTPUT_DIR}/video_technical.json --config ${CODE_ROOT}/Objective/Video/DOVER/dover.yml --device cuda
