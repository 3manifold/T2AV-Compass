#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path
from statistics import mean
from typing import Any

import torch

VIDEO_EXTENSIONS = {'.mp4', '.avi', '.mov', '.mkv', '.webm', '.m4v'}

ROOT = Path(__file__).resolve().parents[1] / 'Objective' / 'Similarity' / 'LatentSync'
sys.path.insert(0, str(ROOT))

from eval.syncnet.syncnet_eval import SyncNetEval  # noqa: E402
from eval.syncnet_detect import SyncNetDetector  # noqa: E402


def iter_videos(video_dir: Path) -> list[Path]:
    return sorted(p for p in video_dir.iterdir() if p.is_file() and p.suffix.lower() in VIDEO_EXTENSIONS)


def evaluate_one(syncnet: SyncNetEval, video_path: Path, work_root: Path, device: str) -> dict[str, Any]:
    detect_root = work_root / video_path.stem / 'detect_results'
    temp_root = work_root / video_path.stem / 'temp'
    if detect_root.exists():
        shutil.rmtree(detect_root)
    if temp_root.exists():
        shutil.rmtree(temp_root)

    detector = SyncNetDetector(device=device, detect_results_dir=str(detect_root))
    detector(video_path=str(video_path), min_track=50)

    crop_dir = detect_root / 'crop'
    crop_videos = sorted(crop_dir.glob('*.mp4')) if crop_dir.exists() else []
    if not crop_videos:
        raise RuntimeError('no talking face detected')

    offsets = []
    confidences = []
    for crop_video in crop_videos:
        per_face_temp = temp_root / crop_video.stem
        av_offset, _, conf = syncnet.evaluate(video_path=str(crop_video), temp_dir=str(per_face_temp))
        offsets.append(float(av_offset))
        confidences.append(float(conf))

    return {
        'file': str(video_path),
        'filename': video_path.name,
        'sync_confidence': float(mean(confidences)),
        'av_offset': float(mean(offsets)),
        'num_faces': len(crop_videos),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description='Batch lip-sync evaluation')
    parser.add_argument('--video_dir', required=True)
    parser.add_argument('--model_path', required=True)
    parser.add_argument('--output_file', required=True)
    parser.add_argument('--temp_dir', required=True)
    parser.add_argument('--device', default='cuda')
    args = parser.parse_args()

    video_dir = Path(args.video_dir).expanduser().resolve()
    output_file = Path(args.output_file).expanduser().resolve()
    temp_dir = Path(args.temp_dir).expanduser().resolve()
    output_file.parent.mkdir(parents=True, exist_ok=True)
    temp_dir.mkdir(parents=True, exist_ok=True)

    device = args.device if args.device.startswith('cuda') and torch.cuda.is_available() else 'cpu'
    syncnet = SyncNetEval(device=device)
    syncnet.loadParameters(args.model_path)

    results: list[dict[str, Any]] = []
    successes: list[dict[str, Any]] = []
    for video_path in iter_videos(video_dir):
        try:
            result = evaluate_one(syncnet, video_path, temp_dir, device)
            result['success'] = True
            result['error'] = None
            successes.append(result)
        except Exception as exc:  # noqa: BLE001
            result = {
                'file': str(video_path),
                'filename': video_path.name,
                'sync_confidence': None,
                'av_offset': None,
                'num_faces': 0,
                'success': False,
                'error': str(exc),
            }
        results.append(result)

    payload = {
        'metric': 'lipsync',
        'summary': {
            'total_videos': len(results),
            'successful_videos': len(successes),
            'failed_videos': len(results) - len(successes),
            'sync_confidence': {
                'mean': float(mean([item['sync_confidence'] for item in successes])) if successes else 0.0
            },
            'av_offset': {
                'mean': float(mean([item['av_offset'] for item in successes])) if successes else 0.0
            },
        },
        'results': results,
    }
    output_file.write_text(json.dumps(payload, indent=2), encoding='utf-8')
    print(f'Saved results to {output_file}')


if __name__ == '__main__':
    main()