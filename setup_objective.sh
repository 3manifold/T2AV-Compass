#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${ROOT_DIR}/t2av-compass/scripts/common.sh
ensure_cache_layout
ensure_conda
ensure_system_deps
bash ${CODE_ROOT}/scripts/eval_video_aesthetic.sh --setup-only
bash ${CODE_ROOT}/scripts/eval_video_technical.sh --setup-only
bash ${CODE_ROOT}/scripts/eval_audio_aesthetic.sh --setup-only
bash ${CODE_ROOT}/scripts/eval_speech_quality.sh --setup-only
bash ${CODE_ROOT}/scripts/eval_text_video_alignment.sh --setup-only
bash ${CODE_ROOT}/scripts/eval_text_audio_alignment.sh --setup-only
bash ${CODE_ROOT}/scripts/eval_audio_video_alignment.sh --setup-only
bash ${CODE_ROOT}/scripts/eval_av_sync.sh --setup-only
bash ${CODE_ROOT}/scripts/eval_lipsync.sh --setup-only
printf 'Objective setup complete. Cache root: %s\n' ${CACHE_ROOT}
