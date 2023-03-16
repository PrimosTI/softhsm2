#!/bin/sh

#-------------------------------------------------------------------------------
# Copyright (c) 2023 Primos TI
# p11-kit-ssh-connect.sh
#
# Licensed under the MIT License. See LICENSE in the project root for license
# information.
#-------------------------------------------------------------------------------
# Connects to an proxy to forward connections to a p11-kit socket over
# network (SSH). This script is intended to be used with the
# p11-kit-ssh-proxy.sh script.
#
# This script is part of the "Sharing tokens to another host over network"
# example of Virtual PKCS #11 Module SoftHSMv2 by Primos TI project.
#
# See https://github.com/PrimosTI/softhsm2 for more information.
#-------------------------------------------------------------------------------

# The host to which the client connects.
PROXY_HOST=172.16.0.3

# The path to the key file used by the client.
USER_NAME=sample-client
# The path to the key file used by the client.
USER_KEY_FILE=/srv/keys/client.key
# The path to the known hosts file used by the client.
SSH_KNOWN_HOSTS_FILE=/srv/config/known_hosts

# Connect to the proxy.
exec ssh -T -o "GlobalKnownHostsFile ${SSH_KNOWN_HOSTS_FILE}" -i ${USER_KEY_FILE} ${USER_NAME}@${PROXY_HOST}
