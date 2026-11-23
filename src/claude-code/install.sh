#!/bin/sh
# Anthropic Claude Code CLI (native standalone binary).
# Source: https://downloads.claude.ai/claude-code-releases/2.1.323/manifest.json (retrieved 2026-11-23)
# Reference: https://claude.ai/install.sh (retrieved 2026-11-23)
set -eu

VERSION="${VERSION:-2.1.323}"
PINNED_VERSION="2.1.323"
SHA256_LINUX_X64="604d29a6869409106b6a1110bdadcc8b72e8654a5a865d23258f938a696e348e"
SHA256_LINUX_ARM64="452dddff140b5caf00a5410333a3d6db82c73ea2dec74b1541fae18e97d47dca"
SHA256_LINUX_X64_MUSL="8ba3c07a4531a04843048d1ecd4abad2c41fd9a5a52476789a23280ed227d399"
SHA256_LINUX_ARM64_MUSL="62ab6e3383909ca8bd50c5b4422f1730d653052cc527ea62c000de867d0ceb24"

if ! command -v curl >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends curl ca-certificates git
    rm -rf /var/lib/apt/lists/*
  elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache curl ca-certificates git
  fi
fi

is_musl=false
if [ -f /lib/libc.musl-x86_64.so.1 ] || [ -f /lib/libc.musl-aarch64.so.1 ] || ldd /bin/ls 2>&1 | grep -qi musl; then
  is_musl=true
fi

case "$(uname -m)" in
  x86_64|amd64)
    if [ "$is_musl" = true ]; then
      platform="linux-x64-musl"
      sum="$SHA256_LINUX_X64_MUSL"
    else
      platform="linux-x64"
      sum="$SHA256_LINUX_X64"
    fi
    ;;
  aarch64|arm64)
    if [ "$is_musl" = true ]; then
      platform="linux-arm64-musl"
      sum="$SHA256_LINUX_ARM64_MUSL"
    else
      platform="linux-arm64"
      sum="$SHA256_LINUX_ARM64"
    fi
    ;;
  *)
    echo "claude-code feature: unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

url="https://downloads.claude.ai/claude-code-releases/${VERSION}/${platform}/claude"
curl -fsSL -o /tmp/claude "$url"

if [ "$VERSION" = "$PINNED_VERSION" ]; then
  echo "${sum}  /tmp/claude" | sha256sum -c -
fi

install -m 0755 /tmp/claude /usr/local/bin/claude
rm -f /tmp/claude

if [ -n "${_REMOTE_USER:-}" ] && [ -n "${_REMOTE_USER_HOME:-}" ] && [ "$_REMOTE_USER" != "root" ]; then
  mkdir -p "${_REMOTE_USER_HOME}/.claude"
  chown "${_REMOTE_USER}:${_REMOTE_USER}" "${_REMOTE_USER_HOME}/.claude" 2>/dev/null || true
fi

claude --version
