#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
runner="${repo_root}/scripts/ci/run-preset.sh"

if [ ! -x "${runner}" ]; then
  echo "Missing executable ${runner}" >&2
  exit 1
fi

presets=(
  "minimal|[]|--data proto=false --data oci=false"
  "js|[javascript]|--data proto=false --data oci=false"
  "py|[python]|--data proto=false --data oci=false"
  "go|[go]|--data proto=false --data oci=true"
  "java|[java]|--data proto=true --data oci=false"
  "kotlin|[kotlin]|--data proto=false --data oci=false"
  "rust|[rust]|--data proto=false --data oci=false"
  "ruby|[ruby]|--data proto=true --data oci=false"
  "shell|[shell]|--data proto=false --data oci=false"
  "kitchen-sink|[javascript, python, go, java, scala, kotlin, cpp, rust, ruby, shell]|--data proto=false --data oci=true"
  "cpp|[cpp]|--data proto=false --data oci=false"
  "scala|[scala]|--data proto=false --data oci=false"
)

run_one() {
  local wanted="$1"
  local matched=0
  local spec name langs features
  for spec in "${presets[@]}"; do
    IFS='|' read -r name langs features <<<"${spec}"
    if [ "${name}" = "${wanted}" ]; then
      "${runner}" "${name}" "${langs}" "${features}"
      matched=1
      break
    fi
  done
  if [ "${matched}" -eq 0 ]; then
    echo "Unknown preset '${wanted}'." >&2
    exit 2
  fi
}

if [ "$#" -gt 0 ]; then
  for preset_name in "$@"; do
    run_one "${preset_name}"
  done
else
  for spec in "${presets[@]}"; do
    IFS='|' read -r name langs features <<<"${spec}"
    "${runner}" "${name}" "${langs}" "${features}"
  done
fi
