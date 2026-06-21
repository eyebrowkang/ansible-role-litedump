# eyebrowkang.litedump

[English](README.md) | [中文](README.zh-CN.md)

一个用 systemd 定时器做 SQLite 数据库定时备份的 Ansible role。

## 环境要求

- ansible-core >= 2.18.0
- systemd
- `sqlite3` / `sqlite` 包（由 role 自动安装）
- 本地开发需要 [uv](https://docs.astral.sh/uv/)

## Role 变量

### 必填

```yaml
litedump_databases:
  - src: /path/to/database.sqlite   # 源数据库文件
    dest: /backup/location/         # 备份目标目录
```

每个 `src` 用 SQLite 的在线 `.backup` 命令备份（数据库使用中也能得到一致快照，
支持 WAL 模式），写入 `dest`，文件名形如 `{名称}_{时间戳}.sqlite`。

### 可选

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `litedump_retention` | `9` | 每个数据库保留的备份份数（必须 ≥ 1；更旧的会被清理） |
| `litedump_timer_oncalendar` | `"*-*-* 00/8:00:00"` | 备份计划，systemd `OnCalendar` 格式 |
| `litedump_discord_webhook` | `""` | 失败通知用的 Discord webhook URL；留空则关闭通知 |

完整列表见 [`defaults/main.yml`](defaults/main.yml)。

## 依赖

无。

## 示例 Playbook

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

## 特性

- **可靠备份** —— 使用 SQLite 原生在线 `.backup`，数据库使用中也能得到一致快照（支持 WAL 模式）。
- **自动调度** —— 可配置的 systemd 定时器（`OnCalendar`）。
- **保留策略** —— 每个数据库保留最新的 `litedump_retention` 份，其余自动清理。
- **失败通知** —— 可选的 Discord webhook 告警（密钥通过 `EnvironmentFile` 注入，不写进脚本）。
- **加固服务** —— systemd 单元以严格沙箱运行（`ProtectSystem=strict`、`PrivateDevices`、`NoNewPrivileges` 等）。
- **多数据库** —— 一次运行可备份任意多个 SQLite 文件。

## 备份文件命名

备份文件名格式为 `{数据库名}_{时间戳}.sqlite`。

例如：`data_20260107_020000.sqlite`

## 开发与测试

用 [copier](https://copier.readthedocs.io/) + [uv](https://docs.astral.sh/uv/) 管理。
先用 `uv sync` 装好工具链，然后：

```bash
make lint           # yamllint + ansible-lint
make shellcheck     # 渲染 shell 模板并跑 shellcheck
make test           # molecule：docker 场景（converge → 幂等 → 保留清理 → verify）
make test-negative  # molecule：negative 场景 —— 断言坏输入被拒绝
```

role 由两个 molecule 场景支撑：

- **`default`**（docker）—— 在 systemd 容器里部署单元、检查幂等，随后反复触发备份，
  证明保留清理后每个库恰好剩 `litedump_retention` 份，最后用 `sqlite3` 完整性检查
  验证每份备份都能正常读回。
- **`negative`** —— 用非法输入（备份重名、`litedump_retention < 1`）应用 role，
  断言它以预期的校验错误失败 —— 这样输入校验逻辑才真正被覆盖，而不只是 happy path。

拉取后续的模板改进：

```bash
copier update --trust
```

完整流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

MIT

## 作者

eyebrowkang
