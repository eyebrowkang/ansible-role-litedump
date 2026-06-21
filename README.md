# eyebrowkang.litedump

An Ansible role for scheduled SQLite database backups using systemd timers.

## Requirements

- ansible-core >= 2.18.0
- systemd
- sqlite/sqlite3 package (installed by the role)
- [uv](https://docs.astral.sh/uv/) for local development

## Role Variables

### Required Variables

```yaml
litedump_databases:
  - src: /path/to/database.sqlite
    dest: /backup/location/
```

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `litedump_retention` | `9` | Number of backup copies to retain per database |
| `litedump_timer_oncalendar` | `"*-*-* 00/8:00:00"` | Backup schedule in systemd timer OnCalendar format |
| `litedump_discord_webhook` | `""` | Discord webhook URL for failure notifications |

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

- **Secure backups**: Uses SQLite's native `.backup` command for reliable backups
- **Automated scheduling**: Configurable systemd timer for regular backups
- **Retention management**: Automatically removes old backups
- **Error notifications**: Optional Discord webhook alerts on backup failures
- **Hardened service**: systemd service runs with strict security restrictions
- **Multiple databases**: Support for backing up multiple SQLite databases

## Backup Files

Backups are named in format: `{database_name}_{timestamp}.sqlite`

Example: `data_20260107_020000.sqlite`

## Development & testing

Managed with [copier](https://copier.readthedocs.io/) + [uv](https://docs.astral.sh/uv/):

```bash
uv sync          # install dev toolchain
make lint          # yamllint + ansible-lint
make shellcheck    # render shell templates and shellcheck them
make test          # molecule test — docker scenario (+ retention side_effect)
make test-negative # molecule test -s negative — asserts the role REJECTS bad input
```

Pull future template improvements:

```bash
copier update --trust
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow.

## License

MIT

## Author

eyebrowkang
