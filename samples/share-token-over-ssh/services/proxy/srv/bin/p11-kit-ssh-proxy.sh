#!/bin/sh

#-------------------------------------------------------------------------------
# Copyright (c) 2023 Primos TI
# p11-kit-ssh-proxy.sh
#
# Licensed under the MIT License. See LICENSE in the project root for license
# information.
#-------------------------------------------------------------------------------
# Starts a proxy to forward connections to a p11-kit socket over network (SSH).
# This script is intended to be used with the p11-kit-ssh-connect.sh script.
#
# This script is part of the "Sharing tokens to another host over network"
# example of Virtual PKCS #11 Module SoftHSMv2 by Primos TI project.
#
# See https://github.com/PrimosTI/softhsm2 for more information.
#-------------------------------------------------------------------------------

if [ ! -z "$SSH_ORIGINAL_COMMAND" ]; then
    echo "Secure Shell is not allowed to run commands."
    exit 1
fi

# The path to the p11-kit socket.
PROXY_SOCKET=/srv/run/sockets/token1.sock

# HINT: At this point, you can use load and verify the client context for custom
#       authentication purposes.

# HINT: At this point, you can identify the client to apply custom ACL's and
#       select the correct p11-kit socket to connect to.

# Run socat to listen on the proxy port and forward to the p11-kit socket.
# See https://www.mankier.com/1/socat for more information.
exec socat - UNIX:${PROXY_SOCKET}
