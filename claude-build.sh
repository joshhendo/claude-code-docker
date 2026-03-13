#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker build --tag claude-proxy:latest --file "${SCRIPT_DIR}/Dockerfile.proxy" "${SCRIPT_DIR}"
docker build --tag claude-code:latest --file "${SCRIPT_DIR}/Dockerfile.code" "${SCRIPT_DIR}"
