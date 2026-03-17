#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
INPUT_DIR=${1:-input}
PROMPTS_JSON=${2:-t2av-compass/Data/prompts.json}
OUTPUT_DIR=${3:-Output}
bash ${ROOT_DIR}/t2av-compass/scripts/eval_all_metrics.sh ${INPUT_DIR} ${PROMPTS_JSON} ${OUTPUT_DIR}
