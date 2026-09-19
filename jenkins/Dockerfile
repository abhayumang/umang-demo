FROM jenkins/jenkins:lts-jdk17

# MinIO client (mc): download link band hone ki wajah se official image se binary copy karte hain
COPY --from=minio/mc:latest /usr/bin/mc /usr/local/bin/mc

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends maven git curl jq tzdata \
 && rm -rf /var/lib/apt/lists/*

USER jenkins
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator git github pipeline-utility-steps \
    lockable-resources pipeline-stage-view timestamper