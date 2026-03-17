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
CLAUDE_DEFAULTS_FILE="${SCRIPT_DIR}/defaults/claude.defaults.json"
CLAUDE_SETTINGS_FILE="${CLAUDE_CONFIG_DIR}/settings.json"
CLAUDE_SETTINGS_DEFAULTS_FILE="${SCRIPT_DIR}/defaults/settings.defaults.json"
CLAUDE_MD_FILE="${CLAUDE_CONFIG_DIR}/CLAUDE.md"
CLAUDE_MD_DEFAULTS_FILE="${SCRIPT_DIR}/defaults/CLAUDE.md"
ENV_DIR="${SCRIPT_DIR}/claude/envs"

# Ensure host-side mounts exist as the correct types before Docker touches them.
# Docker auto-creates a *directory* for any missing bind-mount path, which breaks file mounts.
mkdir -p "${CLAUDE_CONFIG_DIR}"
if [ ! -f "${CLAUDE_CONFIG_FILE}" ]; then
  cp "${CLAUDE_DEFAULTS_FILE}" "${CLAUDE_CONFIG_FILE}"
fi
if [ ! -f "${CLAUDE_SETTINGS_FILE}" ]; then
  cp "${CLAUDE_SETTINGS_DEFAULTS_FILE}" "${CLAUDE_SETTINGS_FILE}"
fi
if [ ! -f "${CLAUDE_MD_FILE}" ]; then
  cp "${CLAUDE_MD_DEFAULTS_FILE}" "${CLAUDE_MD_FILE}"
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


# Parse --add-dir arguments, mounting each host path under /refs in the container
# and rewriting the arg to use the container path.
#
# Syntax: --add-dir /host/path[:ref_name]
#   /host/path        — mounted at /refs/<basename of path>
#   /host/path:name   — mounted at /refs/name
#
# Duplicate ref names are treated as an error.
ADD_DIR_VOLUMES=()
ADD_DIR_NAMES=()
CLAUDE_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --add-dir|--add-dir=*)
      if [[ "$1" == "--add-dir" ]]; then
        RAW="$2"; shift 2
      else
        RAW="${1#--add-dir=}"; shift
      fi
      # Split on colon into host path and optional ref name
      HOST_PATH="${RAW%%:*}"
      if [[ "$RAW" == *:* ]]; then
        REF_NAME="${RAW#*:}"
      else
        REF_NAME="$(basename "${HOST_PATH}")"
      fi
      # Check for duplicate ref names
      for existing in "${ADD_DIR_NAMES[@]}"; do
        if [[ "$existing" == "$REF_NAME" ]]; then
          echo "error: duplicate --add-dir ref name '${REF_NAME}'" >&2
          exit 1
        fi
      done
      ADD_DIR_NAMES+=("${REF_NAME}")
      CONTAINER_PATH="/refs/${REF_NAME}"
      ADD_DIR_VOLUMES+=("--volume" "${HOST_PATH}:${CONTAINER_PATH}:ro")
      CLAUDE_ARGS+=("--add-dir" "${CONTAINER_PATH}")
      ;;
    *)
      CLAUDE_ARGS+=("$1")
      shift
      ;;
  esac
done

ENV_ARGS=()
# Check if the directory exists
if [ -d "$ENV_DIR" ]; then
    # Iterate through every file in the directory
    for env_file in "$ENV_DIR"/*; do
        # Ensure it's a file (not a subfolder)
        if [ -f "$env_file" ]; then
            ENV_ARGS+=("--env-file" "$env_file")
            echo "Loaded environment file: $env_file"
        fi
    done
else
    echo "Warning: $ENV_DIR directory not found. Proceeding without extra env files."
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
  "${ADD_DIR_VOLUMES[@]}" \
  "${ENV_ARGS[@]}" \
  --env NO_PROXY="localhost,127.0.0.1" \
  "${CODE_IMAGE}" "${CLAUDE_ARGS[@]}"
