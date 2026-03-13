#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker compose --file "${SCRIPT_DIR}/docker-compose.yml" build proxy
docker compose --file "${SCRIPT_DIR}/docker-compose.yml" build code
