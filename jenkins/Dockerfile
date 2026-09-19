FROM jenkins/jenkins:lts-jdk17

USER root
ARG TARGETARCH
RUN apt-get update \
 && apt-get install -y --no-install-recommends maven git curl jq tzdata \
 && rm -rf /var/lib/apt/lists/*

# MinIO client (mc) - Intel/AMD aur Apple Silicon dono ke liye
RUN curl -fsSL "https://dl.min.io/client/mc/release/linux-${TARGETARCH:-amd64}/mc" -o /usr/local/bin/mc \
 && chmod +x /usr/local/bin/mc

USER jenkins
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator git github pipeline-utility-steps \
    lockable-resources pipeline-stage-view timestamper
