# Contributing / Development

## Environment

Tooling is managed with [uv](https://docs.astral.sh/uv/); common tasks are
wrapped in the [Makefile](Makefile):

```bash
uv sync          # dev toolchain (docker scenario)

make lint        # yamllint + ansible-lint
make shellcheck  # render the shell templates and shellcheck them
make test        # molecule test — docker scenario (fast; what CI runs)
make converge    # converge the docker instance, keep it for debugging
make destroy     # tear it down
```

Optional pre-commit hooks: `uv sync && uvx pre-commit install` (config in
`.pre-commit-config.yaml`). This role is managed with
[copier](https://copier.readthedocs.io/); pull template improvements with
`copier update --trust`.

## Test scenario

| Scenario  | Driver | Purpose                                                       |
| --------- | ------ | ------------------------------------------------------------- |
| `default` | docker | What CI runs: debian12 / rockylinux9 (`MOLECULE_DISTRO` matrix — the two sqlite package branches) |

The scenario seeds a test SQLite database (`prepare.yml`), converges the role,
checks idempotence, then verifies the script/service/timer are installed, the
timer is active, and a manual backup run produces a valid SQLite copy. The role
needs no real VM, so there is no vagrant scenario.

## Workflow

- `main` is locked: changes land via PR, required checks must pass
  (`lint`, `molecule-docker (debian12)`, `molecule-docker (rockylinux9)`, `pr-title`).
- PRs are **squash-merged** and the **PR title becomes the commit message**,
  so it must follow [Conventional Commits](https://www.conventionalcommits.org/):
  `feat:` (minor bump), `fix:` (patch), `feat!:`/`BREAKING CHANGE` (major),
  plus `docs:` / `test:` / `refactor:` / `chore:` / `ci:` (no release).
  Individual commits inside a PR can be messy — only the title matters.

## Releases

[release-please](https://github.com/googleapis/release-please) maintains a
release PR from the conventional commit history (version bump + CHANGELOG).
**Merging that PR is the entire release process**: it tags `vX.Y.Z`, creates
the GitHub release, and the same workflow imports the role into Ansible
Galaxy (`GALAXY_API_KEY` repo secret).

### Required secrets

| Secret             | Purpose                                                          |
| ------------------ | ---------------------------------------------------------------- |
| `GALAXY_API_KEY`   | Galaxy import on release                                          |
| `AUTOMATION_TOKEN` | Fine-grained PAT (Contents, Pull requests, Issues — read/write). PRs created with the default `GITHUB_TOKEN` never trigger `pull_request` workflows, so without this token the release-please PR would sit forever without its required CI checks. |

## Repository setup (maintainers)

One-time repo governance — branch protection, squash-only merges, Actions
token, required checks — is applied with the scaffold's `scripts/setup-repo.sh`,
run after the first CI run (from a checkout of the `ansible-development`
scaffold):

```bash
scripts/setup-repo.sh eyebrowkang/ansible-role-litedump \
  "lint,molecule-docker (debian12),molecule-docker (rockylinux9),pr-title"
```

Then set the `GALAXY_API_KEY` and `AUTOMATION_TOKEN` secrets (see above).
