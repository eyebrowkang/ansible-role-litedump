# eyebrowkang.litedump

An Ansible role for scheduled SQLite database backups using systemd timers.

## Requirements

- Ansible 2.16+
- systemd
- sqlite/sqlite3 package

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

## License

MIT

## Author

eyebrowkang
