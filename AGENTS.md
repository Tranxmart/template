# AGENTS.md

## Cursor Cloud specific instructions

This is a **Copier template repository** (not a running application). It generates Bazel monorepo projects via `copier copy`.

### Quick reference

- **Prerequisites**: Python 3.12+, Copier >= 9.2.0, Git, Bazelisk (for testing generated projects), direnv (for generated project dev env)
- **Generate a test project**: See `README.md` "Development" section for the full `copier copy` command with all `--data` flags
- **CI workflow**: `.github/workflows/ci.yaml` — generates projects for 12 presets (minimal, js, py, go, java, kotlin, rust, ruby, shell, kitchen-sink, cpp, scala) and runs Bazel build + user stories on each
- **User stories**: `user_stories/*.md` files are executable Markdown scripts tested in CI

### Non-obvious caveats

- When generating with `--skip-tasks`, the `modules_mapping` Bazel target will fail because the `repin` post-generation task hasn't run. This is expected. To test specific build targets, use `bazel build //tools/...` instead of `bazel build ...`.
- Copier requires the template directory to be a git repo with at least one commit. When testing from the workspace, the repo is already initialized. When testing from a fresh clone, `git init && git add . && git commit` in the generated project is required before running Bazel.
- The `_exclude` list in `copier.yml` controls conditional file inclusion based on selected languages/features. When adding new language support, update both the template files and the exclude patterns.
- Template files use `.jinja` suffix for Jinja2 processing; the suffix is stripped in the output. Files without `.jinja` are copied verbatim.
