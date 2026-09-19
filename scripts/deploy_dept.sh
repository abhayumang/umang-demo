#!/usr/bin/env bash
# Usage: deploy_dept.sh <dept-id> <version>
# MinIO se WAR uthata hai, department ke Tomcat me deploy karta hai, health check karta hai.
# (AWS me yehi kaam SSM Run Command / CodeDeploy karta.)
set -euo pipefail
source "$(dirname "$0")/lib.sh"

DEPT="$1"
VERSION="$2"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "[$DEPT] downloading umang $VERSION from MinIO"
s3 cp "s3://${BUCKET}/umang/${VERSION}/umang.war" "$TMP/umang.war" --only-show-errors

echo "[$DEPT] deploying $VERSION"
OUT="$(curl -sS -m 60 -u "${TOMCAT_USER}:${TOMCAT_PASSWORD}" -T "$TMP/umang.war" \
      "http://${DEPT}:8080/manager/text/deploy?path=/umang&update=true" || true)"
echo "[$DEPT] $OUT"
case "$OUT" in
  OK*) ;;
  *) echo "[$DEPT] DEPLOY FAILED"; exit 1 ;;
esac

echo "[$DEPT] health check"
for i in $(seq 1 15); do
  BODY="$(curl -s -m 3 "http://${DEPT}:8080/umang/health" || true)"
  if echo "$BODY" | jq -e --arg v "$VERSION" '.status=="UP" and .version==$v' >/dev/null 2>&1; then
    echo "[$DEPT] HEALTHY on $VERSION"
    exit 0
  fi
  sleep 2
done

echo "[$DEPT] HEALTH CHECK FAILED (last response: ${BODY:-none})"
exit 1
