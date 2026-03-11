#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
runner="${repo_root}/scripts/ci/run-preset.sh"
preset_lister="${repo_root}/scripts/ci/list-presets.py"

if [ ! -x "${runner}" ]; then
  echo "Missing executable ${runner}" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to resolve presets from ${preset_lister}" >&2
  exit 1
fi

list_cmd=(python3 "${preset_lister}" --format tsv)

if [ "$#" -gt 0 ]; then
  for preset_name in "$@"; do
    list_cmd+=(--name "${preset_name}")
  done
fi

mapfile -t preset_rows < <("${list_cmd[@]}")
for row in "${preset_rows[@]}"; do
  IFS=$'\t' read -r name langs features <<<"${row}"
  "${runner}" "${name}" "${langs}" "${features}"
done
