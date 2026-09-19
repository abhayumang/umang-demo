#!/usr/bin/env bash
# Chhota key-value store MinIO me.
# Usage: state.sh get <key>   |   state.sh set <key> <value>
# Keys: latest.version (publish hua), approved.version (poori rollout pass hui)
set -euo pipefail
source "$(dirname "$0")/lib.sh"

case "${1:-}" in
  get) mc cat "minio/${BUCKET}/$2" 2>/dev/null || true ;;
  set) printf '%s' "$3" | mc pipe "minio/${BUCKET}/$2" >/dev/null ;;
  *)   echo "usage: state.sh get <key> | set <key> <value>" >&2; exit 2 ;;
esac
