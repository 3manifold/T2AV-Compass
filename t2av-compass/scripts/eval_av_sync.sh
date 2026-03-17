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
ensure_synchformer_env
if [[ ${SETUP_ONLY} -eq 1 ]]; then
  echo t2av-synchformer ready
  exit 0
fi
INPUT_DIR=$(resolve_path ${1:-input})
OUTPUT_DIR=$(resolve_path ${2:-Output})
SYNC_ROOT=${CODE_ROOT}/Objective/Similarity/Synchformer-main
require_dir ${INPUT_DIR}
require_video_files ${INPUT_DIR}
mkdir -p ${OUTPUT_DIR}
export PYTHONPATH=${SYNC_ROOT}:${SYNC_ROOT}/model/modules/feat_extractors/visual:${PYTHONPATH:-}
(
  cd ${SYNC_ROOT}
  conda_run_in t2av-synchformer python batch_test_folder.py --folder ${INPUT_DIR} --exp_name 24-01-04T16-39-21 --output ${OUTPUT_DIR}/av_sync.json --device cuda:0
)