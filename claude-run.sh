#!/bin/bash
set -e

BASE_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"

CODE_IMAGE="claude-code:latest"
PROXY_IMAGE="claude-proxy:latest"
PROXY_CONTAINER="claude-proxy"
NETWORK="claude-net"

CLAUDE_CONFIG_DIR="${SCRIPT_DIR}/claude/config"
CLAUDE_CONFIG_FILE="${SCRIPT_DIR}/claude/claude.json"
CLAUDE_DEFAULTS_FILE="${SCRIPT_DIR}/claude/claude.defaults.json"
CLAUDE_SETTINGS_FILE="${CLAUDE_CONFIG_DIR}/settings.json"
CLAUDE_SETTINGS_DEFAULTS_FILE="${SCRIPT_DIR}/claude/settings.defaults.json"

# Ensure host-side mounts exist as the correct types before Docker touches them.
# Docker auto-creates a *directory* for any missing bind-mount path, which breaks file mounts.
mkdir -p "${CLAUDE_CONFIG_DIR}"
if [ ! -f "${CLAUDE_CONFIG_FILE}" ]; then
  cp "${CLAUDE_DEFAULTS_FILE}" "${CLAUDE_CONFIG_FILE}"
fi
if [ ! -f "${CLAUDE_SETTINGS_FILE}" ]; then
  cp "${CLAUDE_SETTINGS_DEFAULTS_FILE}" "${CLAUDE_SETTINGS_FILE}"
fi

if ! docker network inspect "${NETWORK}" &>/dev/null; then
  docker network create --internal "${NETWORK}" > /dev/null
fi

# Start hte proxy container
if ! docker inspect --format '{{.State.Running}}' "${PROXY_CONTAINER}" 2>/dev/null | grep -q true; then
  docker run \
    --detach \
    --rm \
    --name "${PROXY_CONTAINER}" \
    --network "${NETWORK}" \
    "${PROXY_IMAGE}" > /dev/null

    # Add to the default bridge so it can access the internet
    docker network connect bridge "${PROXY_CONTAINER}" > /dev/null
fi


echo "Starting Claude Code in: ${BASE_DIR}"

docker run \
  --rm \
  --interactive \
  --tty \
  --network "${NETWORK}" \
  --volume "${BASE_DIR}:/project" \
  --volume "${CLAUDE_CONFIG_DIR}:/home/coder/.claude" \
  --volume "${CLAUDE_CONFIG_FILE}:/home/coder/.claude.json" \
  --env HTTPS_PROXY="http://${PROXY_CONTAINER}:3128" \
  --env NO_PROXY="localhost,127.0.0.1" \
  "${CODE_IMAGE}" "$@"
