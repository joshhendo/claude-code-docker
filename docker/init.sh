#!/bin/bash
# set -e

# init.sh — container entrypoint
# Runs Claude Code as the `coder` user (already set via Dockerfile.code USER directive).
# Any arguments passed to `docker run` are forwarded straight to claude.

# Safety net: if ~/.claude.json wasn't bind-mounted as a file (e.g. docker-compose was run
# without the setup service), initialize from the baked-in defaults.
if [ ! -f /home/coder/.claude.json ]; then
  rm -rf /home/coder/.claude.json 2>/dev/null || true
  cp /home/coder/claude.defaults.json /home/coder/.claude.json
  chown coder:coder /home/coder/.claude.json
fi

exec gosu coder claude --dangerously-skip-permissions "$@"
