#!/bin/sh

#-------------------------------------------------------------------------------
# Copyright (c) 2023 Primos TI
# p11-kit-ssl-connect.sh
#
# Licensed under the MIT License. See LICENSE in the project root for license
# information.
#-------------------------------------------------------------------------------
# Connects to a SSL/TLS proxy to forward connections to a p11-kit socket over
# network. This script is intended to be used with the p11-kit-ssl-proxy.sh
# script.
#
# This script is part of the "Sharing tokens to another host over network"
# example of Virtual PKCS #11 Module SoftHSMv2 by Primos TI project.
#
# See https://github.com/PrimosTI/softhsm2 for more information.
#-------------------------------------------------------------------------------

# The host to which the client connects.
PROXY_HOST=172.16.0.19
# The port to which the client connects.
PROXY_PORT=12345

# The path to the certificate file used by the client.
SSL_CERT_FILE=/srv/keys/client.cer
# The path to the key file used by the client.
SSL_KEY_FILE=/srv/keys/client.key
# The path to the CA file used by the client to verify the server certificate.
SSL_CA_FILE=/srv/keys/ca.cer

# socat server connection arguments.
# OPENSSL: Tries to establish a SSL/TLS connection to TCP service.
CONNECT_ARGS=OPENSSL:${PROXY_HOST}:${PROXY_PORT},cert=${SSL_CERT_FILE},key=${SSL_KEY_FILE},cafile=${SSL_CA_FILE},verify=1
# socat target arguments.
# STDOUT: Outputs to stdout.
TARGET_ARGS=STDOUT

# Run socat to connect to the proxy.
# See https://www.mankier.com/1/socat for more information.
exec socat "${CONNECT_ARGS}" "${TARGET_ARGS}"
