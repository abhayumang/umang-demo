#!/usr/bin/env bash
# Usage: publish_war.sh <version> <path-to-war>
set -euo pipefail
source "$(dirname "$0")/lib.sh"

VERSION="$1"
WAR="$2"

mc mb --ignore-existing "minio/${BUCKET}" >/dev/null
mc cp "$WAR" "minio/${BUCKET}/umang/${VERSION}/umang.war" >/dev/null
printf '%s' "$VERSION" | mc pipe "minio/${BUCKET}/latest.version" >/dev/null
echo "Published umang ${VERSION} -> minio/${BUCKET}/umang/${VERSION}/umang.war"
