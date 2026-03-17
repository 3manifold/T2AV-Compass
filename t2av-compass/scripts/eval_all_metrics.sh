#!/usr/bin/env bash
set -euo pipefail
source $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/common.sh
INPUT_DIR=${1:-input}
PROMPTS_JSON=${2:-t2av-compass/Data/prompts.json}
OUTPUT_DIR=${3:-Output}
ABS_INPUT=$(resolve_path ${INPUT_DIR})
ABS_PROMPTS=$(resolve_path ${PROMPTS_JSON})
ABS_OUTPUT=$(resolve_path ${OUTPUT_DIR})
require_dir ${ABS_INPUT}
require_file ${ABS_PROMPTS}
require_video_files ${ABS_INPUT}
mkdir -p ${ABS_OUTPUT}

bash ${CODE_ROOT}/scripts/eval_video_aesthetic.sh ${INPUT_DIR} ${OUTPUT_DIR}
bash ${CODE_ROOT}/scripts/eval_video_technical.sh ${INPUT_DIR} ${OUTPUT_DIR}
bash ${CODE_ROOT}/scripts/eval_audio_aesthetic.sh ${INPUT_DIR} ${OUTPUT_DIR}
bash ${CODE_ROOT}/scripts/eval_speech_quality.sh ${INPUT_DIR} ${OUTPUT_DIR}
bash ${CODE_ROOT}/scripts/eval_text_video_alignment.sh ${INPUT_DIR} ${PROMPTS_JSON} ${OUTPUT_DIR}
bash ${CODE_ROOT}/scripts/eval_text_audio_alignment.sh ${INPUT_DIR} ${PROMPTS_JSON} ${OUTPUT_DIR}
bash ${CODE_ROOT}/scripts/eval_audio_video_alignment.sh ${INPUT_DIR} ${OUTPUT_DIR}
bash ${CODE_ROOT}/scripts/eval_av_sync.sh ${INPUT_DIR} ${OUTPUT_DIR}
bash ${CODE_ROOT}/scripts/eval_lipsync.sh ${INPUT_DIR} ${OUTPUT_DIR}

${PYTHON_BIN} - <<PY
import json
from datetime import datetime
from pathlib import Path
output_dir = Path(${ABS_OUTPUT@Q})
summary = {
    'timestamp': datetime.now().isoformat(),
    'input_dir': ${ABS_INPUT@Q},
    'prompts_file': ${ABS_PROMPTS@Q},
    'metrics': {},
}
for json_file in sorted(output_dir.glob('*.json')):
    if json_file.name == 'evaluation_summary.json':
        continue
    data = json.loads(json_file.read_text(encoding='utf-8'))
    summary['metrics'][json_file.stem] = data.get('summary', {})
(output_dir / 'evaluation_summary.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
print(f"Saved summary to {output_dir / 'evaluation_summary.json'}")
PY
