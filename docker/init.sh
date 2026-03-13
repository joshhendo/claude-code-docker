#!/bin/bash
# set -e
 
# init.sh — container entrypoint
# Runs Claude Code as the `coder` user (already set via Dockerfile USER directive).
# Any arguments passed to `docker run` are forwarded straight to claude.
 
exec gosu coder claude --dangerously-skip-permissions "$@"
