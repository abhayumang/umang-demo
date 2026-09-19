#!/usr/bin/env bash
# Usage: publish_war.sh <version> <path-to-war>
set -euo pipefail
source "$(dirname "$0")/lib.sh"

VERSION="$1"
WAR="$2"

# Bucket na ho to bana do (already ho to error ignore)
s3 mb "s3://${BUCKET}" >/dev/null 2>&1 || true
s3 cp "$WAR" "s3://${BUCKET}/umang/${VERSION}/umang.war" --only-show-errors
printf '%s' "$VERSION" | s3 cp - "s3://${BUCKET}/latest.version" --only-show-errors
echo "Published umang ${VERSION} -> s3://${BUCKET}/umang/${VERSION}/umang.war"
