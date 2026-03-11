#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 <preset-name> <langs-json> [features-args]" >&2
  echo "Example: $0 js \"[javascript]\" \"--data proto=false --data oci=false\"" >&2
  exit 2
fi

preset_name="$1"
langs_json="$2"
features_args_raw="${3:-}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for required_bin in copier git bazel direnv; do
  if ! command -v "${required_bin}" >/dev/null 2>&1; then
    echo "Missing required tool '${required_bin}'. Run in devbox or install dependencies first." >&2
    exit 1
  fi
done

tmp_project="$(mktemp -d "/tmp/test_project_${preset_name}.XXXXXX")"
cleanup() {
  if [ "${KEEP_TEST_PROJECT:-0}" != "1" ]; then
    rm -rf "${tmp_project}"
  else
    echo "Keeping generated project for debugging: ${tmp_project}"
  fi
}
trap cleanup EXIT

feature_args=()
if [ -n "${features_args_raw}" ]; then
  read -r -a feature_args <<<"${features_args_raw}"
fi

echo "=== [${preset_name}] generate project ==="
copier copy --trust --skip-tasks --defaults \
  --data "project_name=test_${preset_name}" \
  --data "langs=${langs_json}" \
  "${feature_args[@]}" \
  "${repo_root}" "${tmp_project}"

cd "${tmp_project}"
git init
git add .
git config user.email "noreply@aspect.build"
git config user.name "No One"
git commit -a -m "initial commit" >/dev/null

echo "=== [${preset_name}] verify required files ==="
test -f MODULE.bazel
test -f .bazelrc
test -f BUILD
test -f REPO.bazel
test -f .bazelversion
test -f .envrc
test -f devbox.json

echo "=== [${preset_name}] check no Jinja2 artifacts ==="
if grep -rn '{%\|{%-' . --include='*.bazel' --include='*.bzl' --include='*.bazelrc' --include='BUILD' >/dev/null 2>&1; then
  echo "ERROR: Jinja2 block artifacts found in generated files" >&2
  exit 1
fi

echo "=== [${preset_name}] setup direnv and bazel env ==="
direnv allow .
eval "$(direnv export bash)"
bazel run //tools:bazel_env >/dev/null

echo "=== [${preset_name}] format and idempotency ==="
format
git add -A
if ! git diff --cached --quiet; then
  git commit -m "apply format" >/dev/null
fi
format
git diff --exit-code

echo "=== [${preset_name}] run user story ==="
sh "${repo_root}/user_stories/${preset_name}.md"

if [ "${preset_name}" = "py" ]; then
  echo "=== [${preset_name}] verify expected failing python test ==="
  set +e
  bazel test //app:app_test >/dev/null 2>&1
  test_status=$?
  set -e
  if [ "${test_status}" -eq 0 ]; then
    echo "Expected //app:app_test to fail, but it succeeded." >&2
    exit 1
  fi
  grep "FAILED app/app_test.py::test_bad - assert 1 == 2" "$(bazel info bazel-testlogs)/app/app_test/test.log" >/dev/null
fi

echo "=== [${preset_name}] success ==="
