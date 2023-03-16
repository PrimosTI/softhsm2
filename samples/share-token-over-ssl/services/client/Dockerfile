#-------------------------------------------------------------------------------
# Sample Client Dockerfile
#-------------------------------------------------------------------------------
# This service is an example of a client that uses the PKCS #11 module over
# network (SSH).
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Publish stage
#-------------------------------------------------------------------------------
# This stage is used to arrange the artifacts to copy to the final image.
#-------------------------------------------------------------------------------

FROM alpine:3.17 as publish

ADD etc/              /stage/etc/
ADD srv/              /stage/srv/

#-------------------------------------------------------------------------------
# Base stage
#-------------------------------------------------------------------------------
# This stage is used to install the runtime dependencies for the final image.
#-------------------------------------------------------------------------------

FROM alpine:3.17 as base

RUN apk add --no-cache \
    curl \
    gnutls-utils \
    p11-kit-server \
    socat \
  && curl -sSL https://github.com/rodrigo-speller/atone/releases/download/v0.0.5/atone-install.sh | sh

COPY --from=publish /stage/       /

#-------------------------------------------------------------------------------
# Final image
#-------------------------------------------------------------------------------
# This stage is used to create the final image.
#-------------------------------------------------------------------------------

FROM base as final

# Mount point to keys and certificates directory.
# This keys are shared to example purposes only.
VOLUME [ "/srv/keys" ]

# The running services are supervised by Atone.
CMD [ "atone", "--config=/srv/config/atone.yml" ]
