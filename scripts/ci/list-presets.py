#!/usr/bin/env python3
import argparse
import json
import sys
from pathlib import Path


def load_presets():
    presets_path = Path(__file__).resolve().parent / "presets.json"
    data = json.loads(presets_path.read_text(encoding="utf-8"))
    presets = data.get("presets")
    if not isinstance(presets, list):
        raise ValueError("scripts/ci/presets.json must contain a 'presets' list")
    return presets


def select_presets(presets, names):
    if not names:
        return presets
    by_name = {preset["name"]: preset for preset in presets}
    selected = []
    for name in names:
        if name not in by_name:
            raise ValueError(f"Unknown preset '{name}'")
        selected.append(by_name[name])
    return selected


def validate_fields(presets):
    required_fields = ("name", "langs", "features")
    for preset in presets:
        for field in required_fields:
            if field not in preset:
                raise ValueError(f"Preset missing field '{field}': {preset}")
            if not isinstance(preset[field], str):
                raise ValueError(f"Preset field '{field}' must be a string: {preset}")


def main():
    parser = argparse.ArgumentParser(description="List CI presets from scripts/ci/presets.json")
    parser.add_argument("--format", choices=("json-array", "tsv"), required=True)
    parser.add_argument("--name", action="append", default=[], help="Preset name to select")
    args = parser.parse_args()

    presets = load_presets()
    validate_fields(presets)
    selected = select_presets(presets, args.name)

    if args.format == "json-array":
        print(json.dumps(selected, separators=(",", ":")))
        return 0

    for preset in selected:
        for key in ("name", "langs", "features"):
            if "\t" in preset[key] or "\n" in preset[key]:
                raise ValueError(f"Preset field '{key}' contains unsupported characters: {preset[key]!r}")
        print(f"{preset['name']}\t{preset['langs']}\t{preset['features']}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ValueError as err:
        print(str(err), file=sys.stderr)
        raise SystemExit(2)
