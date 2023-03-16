#-------------------------------------------------------------------------------
# SoftHSMv2 Dockerfile
#-------------------------------------------------------------------------------
# This service is the host of the PKCS #11 module. It is responsible for the
# management of the cryptographic objects and execute cryptographic operations.
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Publish stage
#-------------------------------------------------------------------------------
# This stage is used to arrange the artifacts to copy to the final image.
#-------------------------------------------------------------------------------

FROM alpine:3.17 as publish

ADD srv/              /stage/srv/

#-------------------------------------------------------------------------------
# Base stage
#-------------------------------------------------------------------------------
# This stage is used to install the runtime dependencies for the final image.
#-------------------------------------------------------------------------------

FROM ghcr.io/primosti/softhsm2:latest as base
USER root

# Install runtime dependencies
RUN apk add --no-cache \
    curl \
  && curl -sSL https://github.com/rodrigo-speller/atone/releases/download/v0.0.5/atone-install.sh | sh

COPY --from=publish /stage/   /

#-------------------------------------------------------------------------------
# Final image
#-------------------------------------------------------------------------------
# This stage is used to create the final image.
#-------------------------------------------------------------------------------

FROM base as final
USER softhsm

# Mount point to persistent data.
VOLUME [ "/srv/data" ]

# Mount point to share the PKCS #11 module sockets.
VOLUME [ "/srv/run/sockets" ]

# The running services are supervised by Atone.
CMD [ "atone", "--config=/srv/config/atone.yml" ]
