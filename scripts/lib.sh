#!/usr/bin/env bash
# Common helpers: S3-compatible storage (MinIO ya AWS S3) ko AWS CLI se use karne ke liye.
: "${MINIO_ACCESS_KEY:?MINIO_ACCESS_KEY set nahi hai}"
: "${MINIO_SECRET_KEY:?MINIO_SECRET_KEY set nahi hai}"

BUCKET="${MINIO_BUCKET:-umang-artifacts}"
TOMCAT_USER="${TOMCAT_USER:-deployer}"
TOMCAT_PASSWORD="${TOMCAT_PASSWORD:-deployer123}"

# Credentials env se jaate hain (URL me nahi), isliye password me @ ya / bhi chalega
export AWS_ACCESS_KEY_ID="$MINIO_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$MINIO_SECRET_KEY"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
export AWS_EC2_METADATA_DISABLED=true
export AWS_REQUEST_CHECKSUM_CALCULATION=when_required
export AWS_RESPONSE_CHECKSUM_VALIDATION=when_required

# s3 <aws s3 arguments>  -> MinIO par chalega. AWS par jaate waqt MINIO_ENDPOINT khali kar do.
s3() {
  if [ -n "${MINIO_ENDPOINT:-}" ]; then
    aws --endpoint-url "$MINIO_ENDPOINT" s3 "$@"
  else
    aws s3 "$@"
  fi
}
