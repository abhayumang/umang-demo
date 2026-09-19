FROM jenkins/jenkins:lts-jdk17

USER root
# awscli MinIO ke saath bhi chalta hai (--endpoint-url se) aur AWS par jaate waqt wahi commands kaam aayenge.
# addressing_style=path: MinIO ke liye http://minio:9000/<bucket>/... style URL
RUN apt-get update \
 && apt-get install -y --no-install-recommends maven git curl jq tzdata awscli \
 && rm -rf /var/lib/apt/lists/* \
 && printf '[default]\ns3 =\n    addressing_style = path\n' > /etc/umang-aws-config
ENV AWS_CONFIG_FILE=/etc/umang-aws-config

USER jenkins
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator git github pipeline-utility-steps \
    lockable-resources pipeline-stage-view timestamper
