#!/usr/bin/env bash
# Common helpers: MinIO client ko env variables se configure karta hai.
: "${MINIO_ENDPOINT:?MINIO_ENDPOINT set nahi hai}"
: "${MINIO_ACCESS_KEY:?MINIO_ACCESS_KEY set nahi hai}"
: "${MINIO_SECRET_KEY:?MINIO_SECRET_KEY set nahi hai}"

BUCKET="${MINIO_BUCKET:-umang-artifacts}"
TOMCAT_USER="${TOMCAT_USER:-deployer}"
TOMCAT_PASSWORD="${TOMCAT_PASSWORD:-deployer123}"

# mc ko config file ki jagah env se alias dete hain (parallel deploys me file conflict nahi hota).
# Note: secret key me @ ya / jaise special characters na ho.
_scheme="${MINIO_ENDPOINT%%://*}"
_hostport="${MINIO_ENDPOINT#*://}"
export MC_HOST_minio="${_scheme}://${MINIO_ACCESS_KEY}:${MINIO_SECRET_KEY}@${_hostport}"
