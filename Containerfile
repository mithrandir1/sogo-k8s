ARG REGISTRY=docker.io/library
ARG DEBIAN_VER=12
FROM ${REGISTRY}/debian:${DEBIAN_VER}-slim

ARG SOGO_VER=5.12.3
ARG BUILD_NUMBER=0
ARG REPOSITORY=sogo
ARG VCS_REF
ARG BUILD_DATE

LABEL \
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.vendor="Mithrandir1 <https://github.com/mithrandir1>" \
  org.opencontainers.image.title="SOGo Groupware" \
  org.opencontainers.image.description="SOGo is a groupware server with a focus on scalability and open standards." \
  org.opencontainers.image.version="${SOGO_VER}-debian-12-r${BUILD_NUMBER}" \
  org.opencontainers.image.url="https://github.com/mithrandir1/containers" \
  org.opencontainers.image.source="https://github.com/Alinto/sogo" \
  org.opencontainers.image.licenses="GPL-2.0" \
  org.opencontainers.image.revision="${VCS_REF}" \
  org.opencontainers.image.base.name="${REPOSITORY}"
    
ENV TZ=Europe/Vienna

ARG DEBIAN_FRONTEND=noninteractive
ARG SOGO_DEBIAN_REPOSITORY=http://packages.sogo.nu/nightly/5/debian/
ENV LC_ALL C
COPY entrypoint.sh /

# Prerequisites
RUN echo "Building from repository $SOGO_DEBIAN_REPOSITORY" \
  && apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    gnupg \
    curl \
    gettext-base \
  && curl -o /etc/apt/keyrings/sogo.asc "https://keys.openpgp.org/vks/v1/by-fingerprint/74FFC6D72B925A34B5D356BDF8A27B36A6E2EAE9" \
  && echo "deb [ arch=amd64 signed-by=/etc/apt/keyrings/sogo.asc ] ${SOGO_DEBIAN_REPOSITORY} bookworm bookworm" > /etc/apt/sources.list.d/sogo.list \
  && apt-get update && apt-get install -y --no-install-recommends \
    sogo \
    sogo-activesync \
    sope4.9-gdl1-postgresql \
    ssmtp \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/sogo.list \
  && touch /etc/default/locale \
  && chmod +x /entrypoint.sh

COPY sogo.conf /usr/share/doc/sogo/
USER sogo
ENTRYPOINT [ "/entrypoint.sh" ]