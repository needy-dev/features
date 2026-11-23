# Needy Dev Container Features

Standalone [Dev Container Features](https://containers.dev/implementors/features/) published to `ghcr.io/needy-dev/features/<id>` for use with [Needy](https://github.com/needy-dev/needy) and standard Dev Container tooling.

## Available Features

| Feature | OCI Reference | Synced State |
| --- | --- | --- |
| `claude-code` | `ghcr.io/needy-dev/features/claude-code:1` | `~/.claude` (+ `~/.claude.json` bridge via hooks) |
| `codex` | `ghcr.io/needy-dev/features/codex:1` | `~/.codex` (`dependsOn` Python) |
| `opencode` | `ghcr.io/needy-dev/features/opencode:1` | `~/.local/share/opencode` (with `needy-merge-sqlite`) |
| `pi` | `ghcr.io/needy-dev/features/pi:1` | `~/.pi/agent` |
| `herdr` | `ghcr.io/needy-dev/features/herdr:1` | — |

## Usage in a Needy Profile

```yaml
actor:
  image:
    pull_policy: if-not-present
    layers:
      - feature: ghcr.io/needy-dev/features/claude-code:1
```

See [`profiles/claude-code.yaml`](profiles/claude-code.yaml) and [`docs/adr/0001-claude-code-state-and-identity.md`](docs/adr/0001-claude-code-state-and-identity.md) for multi-instance setup (`claude-1`, `claude-2`, ...).
