# ADR 0001: Claude Code State Persistence and Multi-Instance Identity

- **Status:** Accepted
- **Date:** 2026-11-23

## Context

Running multiple independent Claude Code instances (`claude-1`, `claude-2`, `claude-3`) across Needy actors requires:
1. Isolated, persistent credentials and state (`~/.claude/` and `~/.claude.json`) per instance without concurrent OAuth refresh-token or `.claude.json` write conflicts.
2. Stable per-instance machine identity across runs (OS-level `/etc/machine-id`, `hostname`, SMBIOS/MAC fingerprints, and application-level `userID`).

Needy's `mode: sync` mounts a directory via `sshfs` (`sftp-server`), which cannot bind-mount a single file safely for programs that atomically `rename()` files in `$HOME` (cross-mount `rename` fails with `EXDEV`).

## Decisions

1. **Profile-per-instance binding**: Each instance (`claude-1`, `claude-2`, ...) is a minimal child profile (`extends: claude-code.yaml`) that overrides its sync store (`files.claude.from`) and machine identity.
2. **Single-instance serial execution**: Parallel tasks are distributed across distinct instances (`claude-1` / `claude-2` / `claude-3`) rather than running concurrent runs against the same Claude Code store, avoiding OAuth token rotation and `.claude.json` merge conflicts.
3. **Preserve default Claude Code layout (no `CLAUDE_CONFIG_DIR`)**: Keep Claude Code's native `$HOME/.claude/` and `$HOME/.claude.json` paths so any additional default directories or tooling remain visible. Sync `~/.claude` (filtering volatile caches `debug/`, `shell-snapshots/`, `statsig/`, `todos/`, `file-history/`, `downloads/`, `cache/`), restore `~/.claude/.claude.json` → `~/.claude.json` in `postStartCommand`, and copy `~/.claude.json` → `~/.claude/.claude.json` in `hooks.stop`.
4. **Native binary installation**: Install Anthropic's standalone native binary (`https://downloads.claude.ai/claude-code-releases`) with pinned SHA-256 verification and `DISABLE_AUTOUPDATER=1`, avoiding a Node.js runtime dependency.
5. **Follow-up in `needy-dev/needy`**: Add an optional stable `actor.seed` (defaulting to the run ID) plus `/etc/machine-id` support in `recipe.os` so all recipe-derived machine fingerprints (hostname, `/etc/machine-id`, SMBIOS UUID/serial, MAC) stay deterministic per `claude-N` profile while allowing per-field overrides.

## Consequences

- Each `claude-N` instance has isolated credentials, sessions, and machine identity with zero changes required to Needy's `sshfs` sync engine.
- Because `~/.claude.json` is bridged via `hooks.stop`, a hard actor crash that bypasses `hooks.stop` may lose updates to `~/.claude.json` from that run (whereas `~/.claude/` writes persist live over `sshfs`).
