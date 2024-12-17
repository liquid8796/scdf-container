# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM docker.io/bitnami/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG JAVA_EXTRA_SECURITY_DIR="/bitnami/java/extra-security"
ARG TARGETARCH

LABEL com.vmware.cp.artifact.flavor="sha256:c50c90cfd9d12b445b011e6ad529f1ad3daea45c26d20b00732fae3cd71f6a83" \
      org.opencontainers.image.base.name="docker.io/bitnami/minideb:bookworm" \
      org.opencontainers.image.created="2024-12-10T00:28:13Z" \
      org.opencontainers.image.description="Application packaged by Broadcom, Inc." \
      org.opencontainers.image.documentation="https://github.com/bitnami/containers/tree/main/bitnami/spring-cloud-dataflow/README.md" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.ref.name="2.11.5-debian-12-r4" \
      org.opencontainers.image.source="https://github.com/bitnami/containers/tree/main/bitnami/spring-cloud-dataflow" \
      org.opencontainers.image.title="spring-cloud-dataflow" \
      org.opencontainers.image.vendor="Broadcom, Inc." \
      org.opencontainers.image.version="2.11.5"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

RUN apt-get update ; apt-get install -y dos2unix

COPY prebuildfs /

SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN dos2unix /usr/sbin/install_packages
RUN install_packages ca-certificates curl procps zlib1g
RUN mkdir -p /tmp/bitnami/pkg/cache/ ; cd /tmp/bitnami/pkg/cache/ ; \
    COMPONENTS=( \
      "yq-4.44.6-0-linux-${OS_ARCH}-debian-12" \
      "java-21.0.5-11-1-linux-${OS_ARCH}-debian-12" \
    ) ; \
    for COMPONENT in "${COMPONENTS[@]}"; do \
      if [ ! -f "${COMPONENT}.tar.gz" ]; then \
        curl -SsLf "https://${DOWNLOADS_URL}/${COMPONENT}.tar.gz" -O ; \
        curl -SsLf "https://${DOWNLOADS_URL}/${COMPONENT}.tar.gz.sha256" -O ; \
      fi ; \
      sha256sum -c "${COMPONENT}.tar.gz.sha256" ; \
      tar -zxf "${COMPONENT}.tar.gz" -C /opt/bitnami --strip-components=2 --no-same-owner --wildcards '*/files' ; \
      rm -rf "${COMPONENT}".tar.gz{,.sha256} ; \

      if [ ! -f "spring-cloud-dataflow-2.11.5-linux-amd64-debian-12.tar.gz" ]; then \
        curl -SsLf "https://download850.mediafire.com/jqsbqllm1aug_i2tdJYH3Kt1sheb_s6XbN6wItkiH2qPwP4Q7MlZYKXKOVc-iijPig2eaZsD0WlGvvHG65KhfE7oJ0DH3TwycoaugdEtshOgoiXLkG2Sch2tJd2p6yOKt0Ncm61i5AW9mBYAkRbZioL9eIMF9aTZKbg1y7n57BE/j9f1bb6vlr6x5yy/spring-cloud-dataflow-2.11.5-linux-amd64-debian-12.tar.gz" -O ; \
        tar -zxf "spring-cloud-dataflow-2.11.5-linux-amd64-debian-12.tar.gz" -C /opt/bitnami --strip-components=2 --no-same-owner --wildcards '*/files' ; \
        rm -rf spring-cloud-dataflow-2.11.5-linux-amd64-debian-12.tar.gz ; \
      fi ; \
    done
RUN apt-get autoremove --purge -y curl && \
    apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

COPY rootfs /

RUN find /opt/bitnami/scripts -type f -exec dos2unix {} \;
RUN cd opt/bitnami/scripts/spring-cloud-dataflow ; ls
RUN opt/bitnami/scripts/spring-cloud-dataflow/postunpack.sh
RUN opt/bitnami/scripts/java/postunpack.sh
ENV APP_VERSION="2.11.5" \
    BITNAMI_APP_NAME="spring-cloud-dataflow" \
    JAVA_HOME="/opt/bitnami/java" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/java/bin:$PATH"

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/spring-cloud-dataflow/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/spring-cloud-dataflow/run.sh" ]
