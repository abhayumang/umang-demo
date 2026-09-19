#!/usr/bin/env bash
# Common helpers: MinIO client ko env variables se configure karta hai.
: "${MINIO_ENDPOINT:?MINIO_ENDPOINT set nahi hai}"
: "${MINIO_ACCESS_KEY:?MINIO_ACCESS_KEY set nahi hai}"
: "${MINIO_SECRET_KEY:?MINIO_SECRET_KEY set nahi hai}"

BUCKET="${MINIO_BUCKET:-umang-artifacts}"
TOMCAT_USER="${TOMCAT_USER:-deployer}"
TOMCAT_PASSWORD="${TOMCAT_PASSWORD:-deployer123}"

# Special characters (jaise @ ya /) ko URL me safe karne ke liye encode karte hain
_uri() { jq -rn --arg s "$1" '$s|@uri'; }

# mc ko config file ki jagah env se alias dete hain (parallel deploys me file conflict nahi hota)
_scheme="${MINIO_ENDPOINT%%://*}"
_hostport="${MINIO_ENDPOINT#*://}"
export MC_HOST_minio="${_scheme}://$(_uri "$MINIO_ACCESS_KEY"):$(_uri "$MINIO_SECRET_KEY")@${_hostport}"