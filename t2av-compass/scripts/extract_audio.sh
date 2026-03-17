#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: bash extract_audio.sh <input_dir> <output_dir>" >&2
  exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
mkdir -p "${OUTPUT_DIR}"

shopt -s nullglob nocaseglob
count=0
for video in "${INPUT_DIR}"/*.{mp4,avi,mov,mkv,webm,m4v}; do
  [[ -f "${video}" ]] || continue
  name="$(basename "${video}")"
  stem="${name%.*}"
  output_file="${OUTPUT_DIR}/${stem}.wav"
  ffmpeg -nostdin -hide_banner -loglevel error -y -i "${video}" -vn -ac 1 -ar 16000 "${output_file}"
  count=$((count + 1))
done
shopt -u nullglob nocaseglob

if [[ ${count} -eq 0 ]]; then
  echo "ERROR: no supported video files found in ${INPUT_DIR}" >&2
  exit 1
fi