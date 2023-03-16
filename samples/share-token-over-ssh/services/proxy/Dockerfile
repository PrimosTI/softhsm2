#-------------------------------------------------------------------------------
# SSH Proxy Server Dockerfile
#-------------------------------------------------------------------------------
# This service is responsible for authenticating the client and forwarding the
# the communication between the client and the respective sockets that points to
# the PKCS #11 module.
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Publish stage
#-------------------------------------------------------------------------------
# This stage is used to arrange the artifacts to copy to the final image.
#-------------------------------------------------------------------------------

FROM alpine:3.17 as publish

ADD                   etc/                            /stage/etc/
ADD --chown=1000:1000 home/sample-client/             /stage/home/sample-client/
ADD                   srv/                            /stage/srv/

#-------------------------------------------------------------------------------
# Base stage
#-------------------------------------------------------------------------------
# This stage is used to install the runtime dependencies for the final image.
#-------------------------------------------------------------------------------

FROM alpine:3.17 as base

# Install runtime dependencies
RUN apk add --no-cache \
    curl \
    openssh \
    socat \
  && curl -sSL https://github.com/rodrigo-speller/atone/releases/download/v0.0.5/atone-install.sh | sh

COPY --from=publish /stage/       /

#-------------------------------------------------------------------------------
# Final image
#-------------------------------------------------------------------------------
# This stage is used to create the final image.
#-------------------------------------------------------------------------------

FROM base as final

RUN rm -rf /etc/ssh/ssh_host_rsa_key* /etc/ssh/ssh_host_dsa_key* \
  # Create sample-client user
  && adduser -u 1000 -D sample-client \
  && passwd -u sample-client

# Mount point to access the sockets shared by the PKCS #11 module.
VOLUME [ "/srv/run/sockets" ]

# Mount point to keys and certificates directory.
# This keys are shared to example purposes only.
VOLUME [ "/srv/keys" ]

# Expose SSH to clients.
EXPOSE 22

# The running services are supervised by Atone.
CMD [ "atone", "--config=/srv/config/atone.yml" ]
