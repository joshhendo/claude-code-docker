#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"

CLAUDE_CONFIG_DIR="${SCRIPT_DIR}/claude/config"
CLAUDE_CONFIG_FILE="${SCRIPT_DIR}/claude/claude.json"

docker compose \
  --file "${COMPOSE_FILE}" \
  run \
  --rm \
  code "$@"

#docker run \
#	--rm \
#	--interactive \
#	--tty \
#	--volume "$(pwd):/project" \
#	--volume "${CLAUDE_CONFIG_DIR}:/home/coder/.claude" \
#	--volume "${CLAUDE_CONFIG_FILE}:/home/coder/.claude.json" \
#	claude-code:local "$@"
