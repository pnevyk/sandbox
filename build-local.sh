#!/bin/bash

TAG="${1:-agent-sandbox}"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

docker build \
  -t "$TAG" \
  -f "$SCRIPT_DIR/Dockerfile" \
  "$SCRIPT_DIR"

docker save "$TAG" | msb load
