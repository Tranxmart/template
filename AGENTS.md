# AGENTS.md

## 1) Project Context (understand this first)

This is a **Copier template repository** used to generate a multi-language monorepo based on Bazel and Aspect Workflows.
Most files here are not product code; they are scaffolding templates for future repositories.

- Template overview: `README.md`
- Core Copier config: `copier.yml`
- Generated file templates: `template/`
- Init and update task wrappers: `init.axl`, `update.axl`
- Usage examples and stories: `user_stories/`

---

## 2) Directory Quick Guide (high-frequency paths)

- `copier.yml`
  Defines Copier prompts, defaults, conditional exclusions (`_exclude`), and post-generation tasks (`_tasks`).

- `template/`
  Contains files copied into generated projects.
  - `*.jinja`: processed by Jinja, then `.jinja` suffix is removed.
  - Non-`.jinja` files: copied as-is.

- `template/README.bazel.md.jinja`
  Template for the generated project's developer guide and workflow commands.

- `init.axl`
  Wrapper around `copier copy --trust`; attempts `copier`, `pipx run copier`, or `uvx copier`.

- `update.axl`
  Wrapper around `copier update --trust`; requires `.copier-answers.yml` in the current directory.

---

## 3) Required Workflow for AI Changes

1. **Identify the change layer first**
   - Template behavior changes -> edit `copier.yml`, `template/`, `init.axl`, `update.axl`
   - Repository docs changes -> edit `README.md`, `user_stories/`, and related docs

2. **When adding files or language capabilities, check linked areas**
   - Update conditional logic in `copier.yml` `_exclude`
   - Add or update matching files in `template/`
   - Reflect changes in `README.md` and/or `template/README.bazel.md.jinja`

3. **Keep templates render-safe**
   - Do not break Jinja syntax (`{% ... %}`, `{{ ... }}`)
   - Ensure both enabled/disabled language branches remain valid

4. **Do not treat this as a generated repo**
   - `template/*` files are source templates, not final outputs
   - Optimize for generated-project developer experience

---

## 4) Common Commands (for this repository)

- Enter development environment
  - `devbox shell`

- Validate template generation locally (example)
  - `copier copy --trust --skip-tasks --defaults . /tmp/test_project`

- Common next steps in generated repos
  - `bazel run //tools:bazel_env`
  - `bazel test //...`
  - `bazel run gazelle`

---

## 5) AI Editing Guidance

- Prefer small, testable changes (one theme per change).
- When editing `copier.yml`, verify:
  - language multiselect options and derived booleans stay consistent
  - `_exclude` conditions cover new capabilities
  - `_tasks` do not run language-specific commands when disabled
- When editing `template/tools/BUILD.jinja` or `template/BUILD.jinja`, verify conditional `load()` and rule usage are aligned to avoid rendered errors.

---

## 6) Minimal Validation Checklist (before commit)

- Docs-only changes:
  - structure is complete
  - terminology matches current repository behavior

- Template logic changes:
  - run at least one `copier copy` to a temp directory
  - verify expected files are included/excluded

- Script changes (`*.axl`):
  - error messages are clear when dependencies are missing
  - success path arguments are correct (`--trust`, `--defaults`, `--skip-tasks`)

---

## 7) One-line Mental Model

Treat this repository like the front-end of a project generator:
`copier.yml` defines conditions and config, `template/` defines output sources, and `init.axl`/`update.axl` are execution entry points.
