# Aspect Workflows Template (Copier)

A [Copier](https://copier.readthedocs.io/) template for generating a new Bazel monorepo project using [Aspect CLI](https://aspect.build) and Aspect Workflows.

## Prerequisites

- [Copier](https://copier.readthedocs.io/) >= 9.0.0
- [Git](https://git-scm.com/)

Install copier:

```sh
pip install copier
```

Or with [devbox](https://github.com/jetify-com/devbox):

```sh
devbox shell  # copier is included in devbox.json
```

## Usage

### Create a new project

```sh
copier copy --trust https://github.com/<org>/init <destination>
```

Or from a local clone:

```sh
copier copy --trust ./init my_project
```

### Update an existing project

```sh
cd my_project
copier update --trust
```

## Template Options

### Languages

| Option | Description |
|---|---|
| `javascript` | JavaScript & TypeScript support |
| `python` | Python support |
| `go` | Go support |
| `java` | Java support |
| `scala` | Scala support |
| `kotlin` | Kotlin support |
| `cpp` | C & C++ support |
| `rust` | Rust support |
| `ruby` | Ruby support |
| `shell` | Shell (Bash) support |

### Features

| Option | Description |
|---|---|
| `lint` | Format and linting with [rules_lint](https://github.com/aspect-build/rules_lint) |
| `codegen` | Code generation tools (copier, yeoman, scaffold) |
| `proto` | Protobuf and gRPC support |
| `stamp` | Version stamping for releases |
| `oci` | OCI container support with [rules_oci](https://github.com/bazel-contrib/rules_oci) |

### Example

```sh
copier copy --trust --data project_name=my_app \
  --data javascript=true --data python=true \
  --data lint=true --data stamp=true \
  ./init my_app
```

## Development

This template uses [devbox](https://github.com/jetify-com/devbox) for its development environment.

```sh
# Start the devbox shell
devbox shell

# Test template generation
copier copy --trust --skip-tasks --defaults \
  --data project_name=test_project \
  --data javascript=true --data python=true \
  --data go=false --data java=false --data scala=false \
  --data kotlin=false --data cpp=false --data rust=false \
  --data ruby=false --data shell=true \
  --data codegen=false --data lint=true \
  --data proto=false --data stamp=false --data oci=false \
  . /tmp/test_project
```

### Validate CI locally before push

Use the same preset validation logic as GitHub Actions:

```sh
# Run one preset
./scripts/ci/run-local.sh js

# Run full CI matrix locally
./scripts/ci/run-local.sh
```

Install the pre-push hook so pushes are blocked until local CI passes:

```sh
git config core.hooksPath githooks
```

Optional:

```sh
# Run only selected presets in pre-push
LOCAL_CI_PRESETS="minimal js py" git push

# Skip local CI hook once (for emergencies only)
SKIP_LOCAL_CI=1 git push
```

## Template Structure

```
init/
├── copier.yml          # Copier configuration (questions, exclusions, tasks)
├── template/           # Template files (_subdirectory)
│   ├── MODULE.bazel.jinja    # Jinja2 template files
│   ├── .bazelrc.jinja
│   ├── BUILD.jinja
│   ├── tools/
│   │   ├── BUILD.jinja
│   │   ├── format/BUILD.jinja
│   │   ├── lint/
│   │   │   ├── BUILD.jinja
│   │   │   └── linters.bzl.jinja
│   │   └── ...
│   └── ...              # Static files (copied as-is)
├── devbox.json
└── README.md
```

Files with `.jinja` suffix are processed through Jinja2 templating; the suffix is stripped in the output. Files without `.jinja` are copied as-is. Conditional file inclusion is handled via `_exclude` in `copier.yml`.
