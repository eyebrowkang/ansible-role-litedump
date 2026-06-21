# eyebrowkang.litedump

[English](README.md) | [中文](README.zh-CN.md)

An Ansible role for scheduled SQLite database backups using systemd timers.

## Requirements

- ansible-core >= 2.18.0
- systemd
- `sqlite3` / `sqlite` package (installed by the role)
- [uv](https://docs.astral.sh/uv/) for local development

## Role Variables

### Required

```yaml
litedump_databases:
  - src: /path/to/database.sqlite   # source database file
    dest: /backup/location/         # destination directory
```

Each `src` is copied with SQLite's online `.backup` (consistent even while the
database is in use, WAL mode included) into `dest` as `{name}_{timestamp}.sqlite`.

### Optional

| Variable | Default | Description |
|----------|---------|-------------|
| `litedump_retention` | `9` | Number of backup copies to keep per database (must be ≥ 1; older copies are pruned) |
| `litedump_timer_oncalendar` | `"*-*-* 00/8:00:00"` | Backup schedule in systemd `OnCalendar` format |
| `litedump_discord_webhook` | `""` | Discord webhook URL for failure notifications; empty disables them |

See [`defaults/main.yml`](defaults/main.yml) for the full list.

## Dependencies

None.

## Example Playbook

```yaml
---
- hosts: all
  become: true
  vars:
    litedump_databases:
      - src: /var/lib/app/data.sqlite
        dest: /backups/app/
      - src: /var/lib/website/content.sqlite
        dest: /backups/website/
    litedump_retention: 14
    litedump_timer_oncalendar: "*-*-* 02,14:00:00"
    litedump_discord_webhook: "https://discord.com/api/webhooks/..."
  roles:
    - eyebrowkang.litedump
```

## Features

- **Reliable backups** — SQLite's native online `.backup` produces a consistent snapshot even while the database is in use (handles WAL mode).
- **Automated scheduling** — a configurable systemd timer (`OnCalendar`).
- **Retention management** — keeps the newest `litedump_retention` copies per database and prunes the rest.
- **Failure notifications** — optional Discord webhook alert (the secret is injected via an `EnvironmentFile`, never baked into the script).
- **Hardened service** — the systemd unit runs with strict sandboxing (`ProtectSystem=strict`, `PrivateDevices`, `NoNewPrivileges`, …).
- **Multiple databases** — back up any number of SQLite files in one run.

## Backup Files

Backups are named `{database_name}_{timestamp}.sqlite`.

Example: `data_20260107_020000.sqlite`

## Development & testing

Managed with [copier](https://copier.readthedocs.io/) + [uv](https://docs.astral.sh/uv/).
Install the toolchain with `uv sync`, then:

```bash
make lint           # yamllint + ansible-lint
make shellcheck     # render shell templates and shellcheck them
make test           # molecule: docker scenario (converge → idempotence → retention → verify)
make test-negative  # molecule: negative scenario — asserts bad input is REJECTED
```

Two molecule scenarios back the role:

- **`default`** (docker) — provisions the units on a systemd container, checks
  idempotence, drives the backup repeatedly to prove retention pruning keeps
  exactly `litedump_retention` copies, then verifies each backup round-trips via
  a `sqlite3` integrity check.
- **`negative`** — applies the role with invalid input (a duplicate backup name,
  `litedump_retention < 1`) and asserts it fails with the expected validation
  error, so the input-validation logic is actually covered — not just the happy
  path.

Pull future template improvements:

```bash
copier update --trust
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow.

## License

MIT

## Author

eyebrowkang
