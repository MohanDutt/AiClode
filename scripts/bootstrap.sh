#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON_BIN:-python3}"
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  if command -v python >/dev/null 2>&1; then
    PYTHON_BIN=python
  else
    echo "python3/python is required to run scripts/bootstrap.py" >&2
    exit 1
  fi
fi
exec "$PYTHON_BIN" "$ROOT_DIR/scripts/bootstrap.py" "$@"
