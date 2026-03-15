# t2av-compass Codebase Guide

This document explains the structure and daily usage of the `t2av-compass/` code directory.

## Directory Structure

- `Data/`: Prompt JSON files used for objective/subjective evaluation.
- `Input/`: Local input videos for evaluation (project-local convention).
- `Output/`: Evaluation outputs (JSON results, extracted audio, summaries).
- `Objective/`: Objective metrics and third-party metric implementations.
- `Subjective/`: MLLM-as-a-Judge scripts.
- `scripts/`: Unified shell entry points for metric execution.

## Objective Evaluation

Main entry:

```bash
bash scripts/eval_all_metrics.sh <input_dir> <prompts_json> <output_dir>
```

Examples:

```bash
bash scripts/eval_all_metrics.sh Input Data/prompts.json Output
bash scripts/eval_video_aesthetic.sh Input Output
bash scripts/eval_speech_quality.sh Input Output
```

Detailed script usage:

- `scripts/README.md`

## Subjective Evaluation

Run from `Subjective/`:

```bash
cd Subjective
python eval_checklist.py --video_dir ../Input --prompts_file ../Data/prompts.json --output_file ../Output/instruction_following.json
python eval_realism.py --video_dir ../Input --output_file ../Output/realism.json
```

## Submodule-Backed Components

The following directories are git submodules and must remain synchronized with root `.gitmodules`:

- `Objective/Audio/NISQA`
- `Objective/Audio/audiobox-aesthetics`
- `Objective/Similarity/LatentSync`
- `Objective/Video/DOVER`
- `Objective/Video/aesthetic-predictor-v2-5`

If you see submodule errors, follow `../docs/REPO_MAINTENANCE.md`.

