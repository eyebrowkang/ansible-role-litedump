# Local dev targets (mirror CI). Requires uv: https://docs.astral.sh/uv/
.PHONY: help install deps lint test test-negative converge check destroy shellcheck
help:
	@echo "install   - uv sync (dev toolchain)"
	@echo "lint      - yamllint + ansible-lint"
	@echo "deps      - install Galaxy collections that ansible-lint needs"
	@echo "test      - molecule test (docker scenario; includes the retention side_effect)"
	@echo "test-negative - molecule test -s negative (asserts the role REJECTS bad input)"
	@echo "converge  - molecule converge (docker)"
	@echo "check     - molecule converge --check (dry-run; only if the role is check-mode safe)"
	@echo "destroy   - molecule destroy (docker)"
	@echo "shellcheck - render shell templates and shellcheck them"

install:
	uv sync

# ansible-lint resolves the active molecule scenario's collections (e.g. community.docker,
# used by the docker scenario's create.yml) from the Galaxy install path, so install them
# first — the same step CI runs before linting. molecule's own test sequence installs these
# via dependency:galaxy.
deps:
	uv run ansible-galaxy collection install -r molecule/default/collections.yml

lint: deps
	uv run yamllint .
	uv run ansible-lint
shellcheck:
	uv run bash tests/shellcheck.sh
test:
	uv run molecule test

# Negative scenario: applies the role with bad input and asserts it is REJECTED (the
# happy-path `test` only ever feeds valid fixtures). See molecule/negative/.
test-negative:
	uv run molecule test -s negative

converge:
	uv run molecule converge

# Dry-run: everything after `--` is passed through to ansible-playbook, so this previews
# changes via check mode. Only meaningful if the role is check-mode safe (every task
# supports check mode / sets check_mode appropriately). See docs/molecule-testing.md.
check:
	uv run molecule converge -- --check

destroy:
	uv run molecule destroy
