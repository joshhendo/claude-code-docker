#!/bin/bash
# set -e

# init.sh — container entrypoint
# Runs Claude Code as the `coder` user (already set via Dockerfile.code USER directive).
# Any arguments passed to `docker run` are forwarded straight to claude.

# Safety net: if ~/.claude.json wasn't bind-mounted as a file (e.g. host file was missing),
# initialize from the baked-in defaults.
if [ ! -f /home/coder/.claude.json ]; then
  rm -rf /home/coder/.claude.json 2>/dev/null || true
  cp /home/coder/claude.defaults.json /home/coder/.claude.json
  chown coder:coder /home/coder/.claude.json
fi

# Check for available authentication:
#   - ANTHROPIC_API_KEY env var, or
#   - an existing OAuth session stored in ~/.claude.json
is_authenticated() {
  [ -n "${ANTHROPIC_API_KEY}" ] && return 0
  grep -q '"oauthAccount"' /home/coder/.claude.json 2>/dev/null && return 0
  return 1
}

if ! is_authenticated; then
  printf "No authentication found — you will be prompted to log in.\n"
fi

exec gosu coder env claude --dangerously-skip-permissions "$@"
