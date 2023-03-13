################################################################################
# Dockerfile for SoftHSMv2 maintained by Primos TI
# Copyright (c) 2023 Primos TI
# ------------------------------------------------------------------------------
# Creates an image that contains SoftHSMv2 to be used as a PKCS#11 provider.
#
# The p11-kit server can be used to expose the SoftHSMv2 PKCS#11 provider to
# other containers.
#
# Build stages
# ------------
#
# +------------+    +----------------+    +---------+    +------+    +-------+
# | build-base | -> | build-softhsm2 | -> | publish | -> | base | -> | final |
# +------------+    +----------------+    +---------+    +------+    +-------+
#        |                                     ^
#        |          +----------------+         |
#        +--------> |  build-libp11  | --------+
#                   +----------------+
#
################################################################################

################################################################################
# Build base stage
# ----------------
# This stage is used to install the build dependencies for the other stages.
################################################################################

FROM alpine:3.17 as build-base

RUN apk add --no-cache \
    autoconf \
    automake \
    build-base \
    libtool \
    openssl-dev

################################################################################
# Build SoftHSMv2 stage
# ---------------------
# This stage is used to build SoftHSMv2.
#
# Copyright (c) 2010 .SE, The Internet Infrastructure Foundation
#                    http://www.iis.se
# 
# Copyright (c) 2010 SURFnet bv
#                    http://www.surfnet.nl/en
# 
# All rights reserved.
#
# For more information about SoftHSMv2 please visit the main project on
# [https://github.com/opendnssec/SoftHSMv2].
################################################################################

FROM build-base as build-softhsm2

ARG SOFTHSM2_VERSION=2.6.1
ARG SOFTHSM2_SOURCE=https://github.com/opendnssec/SoftHSMv2/archive/${SOFTHSM2_VERSION}.tar.gz

RUN wget -O softhsm2.tar.gz ${SOFTHSM2_SOURCE} \
  && tar -xf softhsm2.tar.gz \
  && cd SoftHSMv2-* \
  && ./autogen.sh \
  && ./configure \
  && make \
  && make install DESTDIR=/usr/stage/softhsm2

################################################################################
# Build libp11 stage
# ------------------
# This stage is used to build libp11.
#
# Copyright (c) The OpenSC libp11 Project https://github.com/OpenSC/libp11
# 
# For more information about libp11 please visit the main project on
# [https://github.com/OpenSC/libp11].
################################################################################

FROM build-base as build-libp11

ARG LIBP11_VERSION=0.4.12
ARG LIBP11_SOURCE=https://github.com/OpenSC/libp11/releases/download/libp11-${LIBP11_VERSION}/libp11-${LIBP11_VERSION}.tar.gz

RUN wget -O libp11.tar.gz ${LIBP11_SOURCE} \
  && tar -xf libp11.tar.gz \
  && cd libp11-* \
  && ./configure --with-objectstore-backend-db \
  && make \
  && make install DESTDIR=/usr/stage/libp-11

################################################################################
# Publish stage
# -------------
# This stage is used to copy the artifacts from the build stages to the final
# image.
################################################################################

FROM alpine:3.17 as publish

# SoftHSMv2
COPY --from=build-softhsm2  /usr/stage/softhsm2/etc/            /usr/stage/etc
COPY --from=build-softhsm2  /usr/stage/softhsm2/usr/local/lib/  /usr/stage/usr/local/lib
COPY --from=build-softhsm2  /usr/stage/softhsm2/usr/local/bin/  /usr/stage/usr/local/bin
COPY --from=build-softhsm2  /usr/stage/softhsm2/var/            /usr/stage/var

# libp11
COPY --from=build-libp11    /usr/stage/libp-11/usr/lib/         /usr/stage/usr/lib
COPY --from=build-libp11    /usr/stage/libp-11/usr/local/lib/   /usr/stage/usr/local/lib

################################################################################
# Base stage
# ----------
# This stage is used to install the runtime dependencies for the final image.
################################################################################

FROM alpine:3.17 as base

RUN apk add --no-cache \
    gnutls-utils \
    libstdc++ \
    musl \
    openssl \
    p11-kit-server

COPY --from=publish /usr/stage /

################################################################################
# Final image
# -----------
# This stage is used to create the final image that will be used to run the
# SoftHSMv2 PKCS#11 provider.
################################################################################

FROM base as final

LABEL org.opencontainers.image.title="SoftHSMv2"
LABEL org.opencontainers.image.vendor="Primos TI"
LABEL org.opencontainers.image.description="SoftHSMv2 to be used as a PKCS#11 provider"
LABEL org.opencontainers.image.authors="Rodrigo Speller"
LABEL org.opencontainers.image.source="https://github.com/PrimosTI/softhsm2"

RUN adduser -u 1000 -D softhsm \
  && mkdir -p \
    /srv/config \
    /srv/data/tokens \
    /srv/run \
  && chown -R softhsm:softhsm /srv/data/tokens /srv/run

ENV SOFTHSM2_CONF=/srv/config/softhsm2.conf
ENV XDG_RUNTIME_DIR=/srv/run

COPY etc/ /etc
COPY --chown=softhsm:softhsm config/softhsm2.conf ${SOFTHSM2_CONF}

WORKDIR /srv
USER softhsm
CMD [ "softhsm2-util", "--help" ]
